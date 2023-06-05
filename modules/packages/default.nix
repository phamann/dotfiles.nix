{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.packages;
in
{
  options.modules.packages = {
    enable = mkEnableOption "packages";
    additional-packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # nix
        cachix

        # zsh
        zsh-autosuggestions
        zsh-fzf-tab
        zsh-history-substring-search
        zsh-syntax-highlighting
        zsh-z

        # cli
        bat
        fd
        htop
        ripgrep
        starship
        tree
        zoxide

        # tools
        _1password
        dig
        docker
        docker-compose
        fastly
        git-crypt
        google-cloud-sdk
        infra
        jq
        keychain
        kubectl
        pinentry-curses
        yq

        # languages and language tooling
        cargo
        gcc
        gnumake
        go
        gofumpt
        gopls
        java-language-server
        lua
        nodejs
        rnix-lsp
        rustfmt
        terraform
        tfswitch
      ]
      ++ cfg.additional-packages;
  };
}
