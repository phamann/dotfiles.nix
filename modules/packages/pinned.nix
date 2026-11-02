# Upstream release binaries pinned to the exact versions incident.io's repos
# pin (in their mise.toml / CI images). Only for tools where the version
# changes CI-visible output and nixpkgs doesn't carry that version:
#
#   helm           manifests/mise.toml            snapshot rendering is diffed in CI
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
      meta,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version;
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
  # nixpkgs has 3.20.x; a newer helm renders some block scalars differently
  # (e.g. loki's `config.yaml: |2` becomes `|`), failing manifests' CI diff.
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
}
