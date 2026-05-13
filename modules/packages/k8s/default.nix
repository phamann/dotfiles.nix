{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.k8s;
in
{
  options.modules.packages.k8s.enable = mkEnableOption "Kubernetes / cloud-native tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      argocd
      conftest
      k3d
      k9s
      kubeconform
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      open-policy-agent
      sloth
      tilt
    ];
  };
}
