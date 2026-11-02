{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.k8s;
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
      # Pinned to manifests/mise.toml, not nixpkgs' kubernetes-helm: see ../pinned.nix.
      pinned.helm
      kustomize
      open-policy-agent
      sloth
      tilt
    ];
  };
}
