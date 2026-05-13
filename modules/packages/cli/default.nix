{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.cli;
in
{
  options.modules.packages.cli.enable =
    mkEnableOption "general CLI utilities, shell plugins, and cloud CLIs";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # nix
      cachix

      # zsh plugins
      zsh-autosuggestions
      zsh-fzf-tab
      zsh-history-substring-search
      zsh-syntax-highlighting
      zsh-z

      # core CLI utilities
      coreutils
      dig
      fd
      gh
      git-crypt
      grc
      htop
      jq
      just
      keychain
      parallel
      pinentry-curses
      poppler-utils
      ripgrep
      tree
      wireguard-tools
      yq-go
      zoxide

      # cloud CLIs
      _1password-cli
      awscli2
      unstable.fastly
      (google-cloud-sdk.withExtraComponents (
        with google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))

      # macOS-flavoured
      terminal-notifier
    ];
  };
}
