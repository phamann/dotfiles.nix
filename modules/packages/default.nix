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
        jq
        keychain
        pinentry-curses
        yq-go

        # languages and language tooling
        cargo-nextest
        gcc
        gnumake
        go
        gofumpt
        gopls
        java-language-server
        lua
        nodejs
        rnix-lsp
        rust-analyzer
        terraform
        terraform-ls
        tflint
        tfswitch
        viceroy

        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = ["wasm32-wasi"];
        })
      ]
      ++ cfg.additional-packages;
  };
}
