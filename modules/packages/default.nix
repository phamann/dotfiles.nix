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
        fd
        htop
        ripgrep
        starship
        tree
        zoxide
        zellij

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
        goimports-reviser
        gopls
        gotools
        hadolint
        jdk17
        java-language-server
        jdt-language-server
        lua
        lua54Packages.luacheck
        luaformatter
        maven
        nixd
        nixpkgs-fmt
        nodePackages.fixjson
        nodePackages.jsonlint
        nodejs
        open-policy-agent
        regols
        rnix-lsp
        rust-analyzer
        shfmt
        statix
        terraform
        terraform-ls
        tflint
        tfswitch
        yamllint

        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = [ "wasm32-wasi" ];
        })
      ]
      ++ cfg.additional-packages;
  };
}
