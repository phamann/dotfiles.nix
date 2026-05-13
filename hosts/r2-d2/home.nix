{ pkgs, ... }:
{
  imports = [ ../../modules/default.nix ];
  config = {
    home = {
      username = "phamann";
      homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/phamann";
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
      nvim = {
        enable = true;
        dev = true;
      };
      packages = {
        cli.enable = true;
        dev.enable = true;
        k8s.enable = true;
      };
      ssh.enable = true;
      starship.enable = true;
      theme = {
        enable = true;
        flavour = "mocha";
      };
      tmux.enable = true;
      zed.enable = true;
      zellij.enable = true;
      zsh = {
        enable = true;
        work = true;
      };
      opencode.enable = true;

      # incident.io-specific tooling that doesn't yet have a home in the
      # cli/dev/k8s split; moves to profiles/work-laptop.nix in Phase 4.
      # unstable.colima is here pending platform-aware module handling in
      # Phase 3.
      packages.additional-packages = with pkgs; [
        caddy
        grafana-alloy
        haproxy
        ngrok
        unstable.colima
      ];
    };
  };
}
