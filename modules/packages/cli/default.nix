{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf optionals;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.modules.packages.cli;
in
{
  options.modules.packages.cli.enable =
    mkEnableOption "general CLI utilities and shell plugins (universal — no work/dev specifics)";

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
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

        # secrets
        _1password-cli
      ]
      ++ optionals isDarwin [
        # macOS-only — meta.platforms restricts to darwin.
        terminal-notifier
      ];
  };
}
