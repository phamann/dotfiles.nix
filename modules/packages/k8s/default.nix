{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.k8s;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  pinned = pkgs.callPackage ../pinned.nix { };
in
{
  options.modules.packages.k8s.enable = mkEnableOption "Kubernetes / cloud-native tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      argocd
      conftest
      k3d
      kubeconform
      kubectl
      kubectx
      # On the Macs, pinned to manifests/mise.toml rather than nixpkgs'
      # kubernetes-helm: see ../pinned.nix. The pin is a darwin-arm64 binary,
      # so Linux hosts (yoda) keep nixpkgs' helm.
      (if isDarwin then pinned.helm else kubernetes-helm)
      kustomize
      open-policy-agent
      sloth
      tilt
    ];
  };
}
