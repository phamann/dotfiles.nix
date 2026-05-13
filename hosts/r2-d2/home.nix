{ pkgs, ... }: {
  imports = [ ../../modules/default.nix ];
  config = {
    home = {
      username = "phamann";
      homeDirectory =
        "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/phamann";
      stateVersion = "22.11";
    };

    programs.home-manager.enable = true;

    modules = {
      alacritty.enable = false;
      bat.enable = true;
      claude-code.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      ghostty.enable = true;
      git.enable = true;
      gpg.enable = true;
      gui.enable = true;
      kitty.enable = false;
      nvim.enable = true;
      packages.enable = true;
      ssh.enable = true;
      starship.enable = true;
      theme = {
        enable = true;
        flavour = "mocha";
      };
      tmux.enable = true;
      zed.enable = true;
      zellij.enable = true;
      zsh.enable = true;
      opencode.enable = true;

      packages.additional-packages = with pkgs; [
        coreutils
        parallel
        tilt
        argocd
        bun
        graphviz
        kubectl
        ngrok
        unstable.colima
        kubernetes-helm
        caddy
        conftest
        grafana-alloy
        haproxy
        kubeconform
        kustomize
        open-policy-agent
      ];
    };
  };
}
