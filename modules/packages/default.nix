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

        # ai
        aider-chat
        unstable.claude-code
        litellm

        # cli
        fd
        grc
        htop
        ripgrep
        starship
        tree
        zoxide

        # tools
        awscli2
        _1password-cli
        dig
        docker
        docker-compose
        unstable.fastly
        gh
        git-crypt
        (google-cloud-sdk.withExtraComponents
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
        jq
        keychain
        pkg-config
        pinentry-curses
        poppler-utils
        yq-go
        terminal-notifier

        # k8s
        k9s

        # languages and language tooling
        cargo-nextest
        d2
        gcc
        gnumake
        gofumpt
        goimports-reviser
        gotools
        hadolint
        java-language-server
        jdk21_headless
        jdt-language-server
        lld
        lua
        lua54Packages.luacheck
        luaformatter
        maven
        nil
        nixd
        nixfmt-classic
        nixpkgs-fmt
        nodePackages.fixjson
        nodejs
        openssl
        perl
        perl540Packages.CPAN
        regols
        rust-analyzer
        shfmt
        statix
        terraform
        terraform-ls
        tflint
        tfswitch
        typescript
        typescript-language-server
        unstable.go
        unstable.gopls
        wireguard-tools
        yamllint

        unstable.cue

        # ollama

        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = [ "wasm32-wasip1" ];
        })
      ] ++ cfg.additional-packages;
  };
}
