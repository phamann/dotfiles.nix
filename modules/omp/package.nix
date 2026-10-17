# OMP from upstream's prebuilt GitHub release assets, instead of the in-tree
# flake's source build.
#
# `inputs.omp.packages.<system>.default` compiles `pi-natives` with cargo
# (~780 crates, 1.9GB vendored, a 3GB rust nightly toolchain) and then bundles
# the CLI with `bun --compile`: ~12 minutes on an M-series Mac, on every bump
# of the `omp` input, with no binary cache anywhere to substitute from. It also
# breaks independently of nixpkgs — v18.1.21's bun.lock is missing `chalk`, so
# the source build fails outright.
#
# Upstream release CI already builds and smoke-tests these exact binaries for
# every supported platform; `install.sh --binary` and the Homebrew formula both
# install them. This is the same contract, for Nix.
#
# Tracking: https://github.com/can1357/oh-my-pi/issues/10108
# Delete this file and `modules.omp.useBinary` once upstream ships either an
# `omp-bin` output or a binary cache that covers aarch64-darwin.
#
# To bump, set `version` and regenerate the hashes:
#
#   curl -sL https://github.com/can1357/oh-my-pi/releases/download/v<version>/SHA256SUMS.txt \
#     | grep -E 'omp-(darwin|linux)-(x64|arm64)$' \
#     | while read -r h n; do \
#         printf '%-18s %s\n' "$n" "$(nix hash convert --hash-algo sha256 --to sri "$h")"; \
#       done
#
# Keep `version` in step with the `omp` flake input: the home-manager module
# (and so the config schema it writes) comes from the input, the binary from
# here.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "18.1.21";

  # Release asset name + SRI hash per Nix system, from that release's
  # SHA256SUMS.txt. Kept as data so a bump is a hash-only diff.
  sources = {
    aarch64-darwin = {
      asset = "omp-darwin-arm64";
      hash = "sha256-6ZoG1XQfE6XhYciGF83i9aZdQisu7Azxpprs0JOyRi8=";
    };
    x86_64-darwin = {
      asset = "omp-darwin-x64";
      hash = "sha256-zHrEuZybgwIhKpqHlO8APf33ibAkvcGdhc2HzPBngVA=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-Ywhqn2MHpJWV3Dmw3c+el+HmOrsyuXJZVlEgLFi7gzo=";
    };
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-DZ38xFYbWHf1ccrIEib+ihRm2VHLhA4JHz+CpoSz/eQ=";
    };
  };

  inherit (stdenvNoCC.hostPlatform) system;

  source = sources.${system} or (throw "omp-bin: no release asset for system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "omp-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  strictDeps = true;

  # The linux assets are bare ELFs and need the loader plus libstdc++/libgcc
  # patched in. The darwin assets carry upstream's own signature and run as
  # downloaded — the same bytes Homebrew installs.
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
    runHook postInstall
  '';

  # `omp --version` exercises the bun runtime and the embedded native addon,
  # which is the part most likely to be broken by a bad patchelf/signature.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/omp" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal-based coding agent with multi-model support (upstream release binary)";
    homepage = "https://omp.sh";
    changelog = "https://github.com/can1357/oh-my-pi/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = lib.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
