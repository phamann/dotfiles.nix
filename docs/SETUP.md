# New Machine Setup

Steps to configure a new machine from scratch.

---

## 1. Install 1Password

Download and install [1Password](https://1password.com/downloads) manually.

Sign in with your email and Secret Key (retrieve from another device or the Emergency Kit PDF in your existing vault).

### Install 1Password CLI

Enable the CLI via **1Password → Settings → Developer → Command-Line Interface (CLI)**.

Verify:

```zsh
op --version
```

Sign in:

```zsh
eval $(op signin)
```

---

## 2. Create SSH Key

```zsh
ssh-keygen -t ed25519 -C "your@email.com"
# Accept default path (~/.ssh/id_ed25519), set a passphrase
```

Copy the public key:

```zsh
pbcopy < ~/.ssh/id_ed25519.pub
```

---

## 3. Import GPG Key

Import the GPG private key stored in 1Password:

```zsh
op document get private.gpg --output /tmp/private.asc && gpg --allow-secret-key-import --import /tmp/private.asc && rm /tmp/private.asc
```

Verify the key was imported:

```zsh
gpg --list-secret-keys
```

---

## 4. Add SSH Key to GitHub

1. Go to [github.com/settings/keys](https://github.com/settings/keys)
2. **New SSH key** → paste the public key → save

### Test access

```zsh
ssh -T git@github.com
# Expected: Hi phamann! You've successfully authenticated...
```

---

## 5. Install Nix (Determinate Systems)

**macOS:** Use the GUI `.pkg` installer — download from:

```
https://install.determinate.systems/determinate-pkg/stable/Universal
```

Open the `.pkg` and follow the prompts. Or use the CLI instead:

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Linux:** CLI only:

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your shell or source the environment:

```zsh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

---

## 6. Clone Dotfiles

```zsh
git clone git@github.com:phamann/dotfiles.nix.git $HOME/.config/nixpkgs
cd $HOME/.config/nixpkgs
```

---

## 7. Apply Configuration

Run the appropriate target for this machine:

| Host    | Type   | Command        |
|---------|--------|----------------|
| x-wing  | macOS  | `make x-wing`  |
| r2-d2   | macOS  | `make r2-d2`   |
| yoda    | Linux  | `make yoda`    |

```zsh
make <hostname>
```

This will take a while on first run.

---

## 8. Test Configuration

```zsh
# Verify nix-darwin (macOS)
darwin-rebuild --version

# Verify home-manager
home-manager --version

# Check a managed package
which nvim && nvim --version

# Verify shell is correct
echo $SHELL
```

Restart your terminal. If something looks off, check `make help` for available targets.

---

## 9. Working on this repo

Once the machine is up and you want to iterate on the configuration itself, the toolchain comes via the flake's dev shell and Makefile.

### Enter the dev shell

```zsh
nix develop
```

Drops you in a shell with `nixd`, `nixfmt-rfc-style`, `statix`, and `deadnix` available on PATH — even on a fresh clone where the user profile doesn't have them. Used by the pre-commit hooks; useful for ad-hoc linting/formatting.

### Format

```zsh
make fmt        # or: nix fmt
```

Runs `treefmt` with `nixfmt-rfc-style` (RFC 166). Excludes `flake.lock`, `*.lock`, `.gitignore`, and `modules/nvim/config/lazy-lock.json` (generated/vendored).

### Check

```zsh
make check      # or: nix flake check
```

Runs:

- `eval-r2-d2`, `eval-x-wing` (on aarch64-darwin) — builds the toplevel system derivation for each Mac.
- `eval-yoda` (on x86_64-linux) — builds yoda's activation package. Note: on aarch64-darwin this fails because catppuccin's per-app modules import TOML from x86_64-linux derivations that aarch64-darwin can't substitute. CI on Linux closes this gap (see `.github/workflows/check.yml`).
- `treefmt` — formatting check.
- `pre-commit` — statix + deadnix + treefmt.

### Pre-commit hooks

Hooks are NOT auto-installed into `.git/hooks` because `core.hooksPath = ~/.git-hooks` is set globally — `pre-commit install` would write hooks into that shared directory and apply them to every git repo on the machine, not just this one.

To enable per-commit enforcement locally:

```zsh
# Per-repo only — overrides the global core.hooksPath
git config --local --unset core.hooksPath

# Then from `nix develop`:
pre-commit install
```

Otherwise, hooks run via `nix flake check` and CI.

### CI

`.github/workflows/check.yml` runs `nix flake check` on macos-14 and ubuntu-24.04 for every push to main and every PR. yoda's full evaluation happens on the Linux runner.

A separate `lockfile` job runs `DeterminateSystems/flake-checker-action` in report-only mode to surface stale inputs as a PR summary.

### External consumers

Each module is published as a flake output:

```nix
imports = [ inputs.dotfiles.homeManagerModules.<name> ];
```

19 modules total — see `flake/modules.nix`. Some need extra inputs in `extraSpecialArgs`:

- `theme` → `inputs.catppuccin`
- `claude-code` → `inputs.claude-code-nix` and `system`
