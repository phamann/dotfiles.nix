{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.packages;
in {
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
        grc
        htop
        ripgrep
        starship
        tree
        zoxide

        # tools
        _1password-cli
        dig
        docker
        docker-compose
        fastly
        git-crypt
        (google-cloud-sdk.withExtraComponents
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
        jq
        keychain
        pinentry-curses
        yq-go

        # languages and language tooling
        cargo-nextest
        gcc
        gnumake
        unstable.go
        gofumpt
        goimports-reviser
        unstable.gopls
        gotools
        hadolint
        java-language-server
        jdk21_headless
        jdt-language-server
        lua
        lua54Packages.luacheck
        luaformatter
        maven
        nil
        nixd
        nixfmt-classic
        nixpkgs-fmt
        nodePackages.fixjson
        nodePackages.jsonlint
        nodejs
        regols
        rust-analyzer
        shfmt
        statix
        terraform
        terraform-ls
        tflint
        tfswitch
        yamllint

        unstable.cue

        ollama

        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = [ "wasm32-wasip1" ];
        })
      ] ++ cfg.additional-packages;
  };
}
