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
        zsh-fzf-tab
        zsh-z
        zsh-autosuggestions
        zsh-history-substring-search
        zsh-syntax-highlighting

        # cli
        bat
        fd
        htop
        starship
        tree
        ripgrep
        zoxide

        # tools
        _1password
        dig
        jq
        google-cloud-sdk
        docker
        docker-compose
        git-crypt

        # languages and language tooling
        cargo
        gcc
        gnumake
        go
        gofumpt
        gopls
        nodejs
        rnix-lsp
        rustfmt
        terraform
        tfswitch
        lua
      ]
      ++ cfg.additional-packages;
  };
}
