#!/usr/bin/env python3
"""Gather install evidence for one piece of software in a single pass.

Usage (from anywhere inside the repo):
    python3 .claude/skills/install-software/scripts/probe.py <name> [alias ...]
    python3 .claude/skills/install-software/scripts/probe.py <name> --search

<name> and each alias are tried as nixpkgs attribute paths (e.g. `ripgrep`,
`python3Packages.httpie`, `nodePackages.prettier`), home-manager / stylix
module names, and Homebrew cask/formula tokens. `--search` adds a broad
`nix search` against unstable (slow the first time: it evaluates nixpkgs).

Read-only. Everything resolves against the *pinned* inputs in flake.lock, not
the user's nix registry, so the versions printed are the ones a rebuild would
actually install. Nothing here calls `nix eval`.
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path


def run(*cmd, env=None):
    p = subprocess.run(cmd, capture_output=True, text=True, env=env)
    return p.returncode, p.stdout, p.stderr


def section(title):
    print(f"\n== {title} ==")


def repo_root():
    code, out, _ = run("git", "rev-parse", "--show-toplevel")
    if code != 0:
        sys.exit("probe.py: run this from inside the nixpkgs repo")
    return Path(out.strip())


def locked_inputs(root):
    lock = json.loads((root / "flake.lock").read_text())
    nodes = lock["nodes"]
    return {name: nodes[ref]["locked"] for name, ref in nodes["root"]["inputs"].items()
            if isinstance(ref, str)}


def flake_ref(locked):
    if locked.get("type") == "github":
        return f"github:{locked['owner']}/{locked['repo']}/{locked['rev']}"
    return None


def store_path(locked):
    ref = flake_ref(locked)
    if not ref:
        return None
    code, out, _ = run("nix", "flake", "prefetch", "--json", ref)
    return json.loads(out)["storePath"] if code == 0 else None


def nixpkgs_version(ref, attr):
    code, out, _ = run("nix", "search", "--json", f"{ref}#{attr}", "^")
    if code != 0 or not out.strip():
        return None
    hits = json.loads(out)
    if not hits:
        return None
    # Single-attr search returns the attr itself; for package sets it may
    # return children, so take the exact match when present.
    for key, meta in hits.items():
        if key.endswith(f".{attr}"):
            return meta
    return next(iter(hits.values()))


def main():
    args = [a for a in sys.argv[1:] if a != "--search"]
    broad = "--search" in sys.argv
    if not args:
        sys.exit(__doc__)
    name, candidates = args[0], args

    root = repo_root()
    os.chdir(root)
    inputs = locked_inputs(root)

    section("context")
    _, host, _ = run("hostname", "-s")
    _, branch, _ = run("git", "branch", "--show-current")
    print(f"host: {host.strip()}   platform: {os.uname().sysname} {os.uname().machine}")
    print(f"repo: {root}   branch: {branch.strip()}")
    if root != Path.home() / ".config/nixpkgs":
        print("NOTE: not the main checkout — commit here, then land on main in "
              "~/.config/nixpkgs before switching (see SKILL.md).")

    section("already declared in this repo?")
    hits = set()
    for c in candidates:
        token = c.split(".")[-1]
        code, out, _ = run("grep", "-rniw", "--include=*.nix", "-e", token,
                           "modules", "profiles", "hosts", "flake", "flake.nix")
        hits.update(out.splitlines())
    if any(c.split(".")[-1] in inputs for c in candidates):
        hits.add("flake.nix: flake input with this name exists")
    print("\n".join(sorted(hits)[:40]) if hits else "no matches")

    section("home-manager modules (pinned input)")
    hm = store_path(inputs.get("home-manager", {}))
    if hm:
        found = False
        for c in candidates:
            token = c.split(".")[-1]
            for kind in ("programs", "services"):
                for p in (Path(hm, "modules", kind, f"{token}.nix"),
                          Path(hm, "modules", kind, token)):
                    if p.exists():
                        print(f"{kind}.{token}  ->  {p}")
                        found = True
        if not found:
            # Module names don't always match the package (zed -> zed-editor).
            loose = sorted(
                f"{kind}/{p.name}"
                for kind in ("programs", "services")
                for p in Path(hm, "modules", kind).iterdir()
                if any(c.split(".")[-1].lower() in p.name.lower() for c in candidates)
            )
            print("no exact module" + (f"; similar: {', '.join(loose)}" if loose else ""))
        print(f"(source: {hm})")
    else:
        print("could not resolve the home-manager input")

    section("stylix targets (pinned input)")
    sx = store_path(inputs.get("stylix", {}))
    if sx:
        targets = {p.name for p in Path(sx, "modules").iterdir() if p.is_dir()}
        matches = sorted(t for t in targets
                         if any(c.split(".")[-1].lower() in t for c in candidates))
        print(", ".join(matches) if matches else "no stylix target")
    else:
        print("could not resolve the stylix input")

    section("nixpkgs (pinned stable vs unstable)")
    refs = {k: flake_ref(inputs[k]) for k in ("nixpkgs", "nixpkgs-unstable") if k in inputs}
    for c in candidates:
        row, desc = [], ""
        for label, ref in refs.items():
            meta = nixpkgs_version(ref, c) if ref else None
            row.append(f"{label}={meta['version'] or '?'}" if meta else f"{label}=absent")
            desc = (meta or {}).get("description") or desc
        print(f"{c:32} " + "  ".join(row))
        if desc:
            print(f"{'':32} {desc[:100]}")
    if broad and refs.get("nixpkgs-unstable"):
        print(f"\nbroad search for '{name}' in unstable (top 25):")
        code, out, _ = run("nix", "search", "--json", refs["nixpkgs-unstable"], name)
        if code == 0 and out.strip():
            for key, meta in list(json.loads(out).items())[:25]:
                attr = re.sub(r"^legacyPackages\.[^.]+\.", "", key)
                print(f"  {attr:40} {meta['version']:14} {meta['description'][:60]}")

    section("homebrew")
    env = {**os.environ, "HOMEBREW_NO_AUTO_UPDATE": "1", "HOMEBREW_NO_ENV_HINTS": "1"}
    code, _, _ = run("which", "brew")
    if code != 0:
        print("brew not available on this host")
    else:
        for c in candidates:
            token = c.split(".")[-1]
            code, out, _ = run("brew", "info", "--json=v2", "--cask", token, env=env)
            if code == 0:
                k = json.loads(out)["casks"][0]
                apps = [a["app"][0] for a in k.get("artifacts", []) if "app" in a]
                print(f"cask {k['token']}: {', '.join(k['name'])} {k['version']}"
                      f"  apps={apps}  {k['homepage']}"
                      + ("  DEPRECATED" if k.get("deprecated") else "")
                      + ("  DISABLED" if k.get("disabled") else ""))
                print(f"     {k.get('desc') or ''}")
            code, out, _ = run("brew", "info", "--json=v2", "--formula", token, env=env)
            if code == 0:
                f = json.loads(out)["formulae"][0]
                print(f"formula {f['full_name']}: {f['versions']['stable']}  {f['homepage']}")
                print(f"     {f.get('desc') or ''}")
        code, out, _ = run("brew", "search", name, env=env)
        print(f"\nbrew search '{name}':\n{out.strip() or '(nothing)'}")


if __name__ == "__main__":
    main()
