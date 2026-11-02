# Upstream release binaries pinned to the exact versions incident.io's repos
# pin (in their mise.toml / CI images). Only for tools where the version
# changes CI-visible output and nixpkgs doesn't carry that version:
#
#   helm           manifests/mise.toml            snapshot rendering is diffed in CI
#   yq             manifests/mise.toml, core/mise.toml   snapshot YAML formatting
#   pandoc        core/Dockerfile                post-mortem export output
#   golangci-lint  core/.buildkite/docker/Dockerfile.tools   lint findings
#
# Deliberately NOT pinned: grafana-alloy. manifests pins 1.14.2, but that
# release's darwin binary segfaults at startup on macOS 27 (it links
# go-m1cpu v0.1.7; fixed in v0.2.1). nixpkgs' newer alloy stays in the work
# bucket, so manifests' alloy-profiles validation fails locally; CI is fine.
# Revisit when manifests bumps its alloy pin.
#
# Not a module: the package buckets `callPackage` this file and pick entries.
# aarch64-darwin only, because these sit in buckets only the Macs enable.
#
# To bump an entry, set `version` to the repo's new pin and convert
# upstream's published sha256 for the darwin-arm64 asset:
#
#   nix hash convert --hash-algo sha256 --to sri <hex>
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
let
  mkPinned =
    {
      pname,
      version,
      url,
      hash,
      install,
      versionArgs ? "--version",
      mainProgram ? pname,
      # For assets that are a bare binary rather than an archive; `install`
      # then reads "$src" directly.
      dontUnpack ? false,
      meta,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version dontUnpack;
      src = fetchurl { inherit url hash; };

      nativeBuildInputs = [ unzip ];
      # Some assets unpack to a bare file rather than a directory.
      sourceRoot = ".";
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        ${install}
        runHook postInstall
      '';

      # Running the binary catches a wrong path inside the archive or a
      # darwin binary that won't launch.
      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck
        "$out/bin/${mainProgram}" ${versionArgs}
        runHook postInstallCheck
      '';

      meta = meta // {
        inherit mainProgram;
        platforms = [ "aarch64-darwin" ];
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };
in
{
  # nixpkgs has 3.20.x. As of 2026-11 its snapshot output is identical, but
  # manifests' AGENTS.md warns helm versions change snapshot whitespace and
  # CI renders with this exact version, so match it.
  helm = mkPinned rec {
    pname = "helm";
    version = "3.15.4";
    url = "https://get.helm.sh/helm-v${version}-darwin-arm64.tar.gz";
    hash = "sha256-iBFYRqH7WPjrj2T+xcND2VyjlPG+gRYC+lSoh8mHMKw=";
    install = ''install -Dm755 darwin-arm64/helm "$out/bin/helm"'';
    versionArgs = "version --short";
    meta = {
      description = "Kubernetes package manager (upstream release binary)";
      homepage = "https://helm.sh";
      license = lib.licenses.asl20;
    };
  };

  # nixpkgs has 4.53.x, which re-serialises block scalars differently (loki's
  # `config.yaml: |2` becomes `|` plus a blank line), so regenerated manifests
  # snapshots fail CI's diff. Verified: 4.44.3 regenerates them with no diff.
  yq = mkPinned rec {
    pname = "yq";
    version = "4.44.3";
    url = "https://github.com/mikefarah/yq/releases/download/v${version}/yq_darwin_arm64";
    hash = "sha256-VZpZTvem68W4Gme3cX+zrM7dJm2Pp9g1Laf+yeRj9Is=";
    dontUnpack = true;
    install = ''install -Dm755 "$src" "$out/bin/yq"'';
    meta = {
      description = "Portable command-line YAML processor (upstream release binary)";
      homepage = "https://mikefarah.gitbook.io/yq";
      license = lib.licenses.mit;
    };
  };

  # nixpkgs has 3.7.x; core's Dockerfiles pin 3.8.3 and server/lib/pandoc
  # tests compare its output.
  pandoc = mkPinned rec {
    pname = "pandoc";
    version = "3.8.3";
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-arm64-macOS.zip";
    hash = "sha256-Pq6zvRCYKuy6XddhWHRaT4Ba+zmrcqUZu6JTPJjOAC0=";
    install = ''
      mkdir -p "$out"
      cp -R pandoc-${version}-arm64/bin pandoc-${version}-arm64/share "$out/"
    '';
    meta = {
      description = "Universal document converter (upstream release binary)";
      homepage = "https://pandoc.org";
      license = lib.licenses.gpl2Plus;
    };
  };

  # nixpkgs has 2.12.x (stable) / 2.15.x (unstable); core's CI image pins 2.13.0
  # and lint findings change between releases.
  golangci-lint = mkPinned rec {
    pname = "golangci-lint";
    version = "2.13.0";
    url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-darwin-arm64.tar.gz";
    hash = "sha256-curmcAl5eOYbeKdzolwnQ5411UCU/Zhs7l7usl1xRP0=";
    install = ''install -Dm755 golangci-lint-${version}-darwin-arm64/golangci-lint "$out/bin/golangci-lint"'';
    versionArgs = "version";
    meta = {
      description = "Fast linters runner for Go (upstream release binary)";
      homepage = "https://golangci-lint.run";
      license = lib.licenses.gpl3Only;
    };
  };
}
