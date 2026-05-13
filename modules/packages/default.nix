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
        eas-cli
        unstable.fastly
        gh
        git-crypt
        (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
          gke-gcloud-auth-plugin
        ]))
        jq
        just
        k3d
        keychain
        kubectx
        sloth
        pinentry-curses
        pkg-config
        poppler-utils
        terminal-notifier
        yq-go

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
        nodejs_22
        openssl
        python313
        rust-analyzer
        semgrep
        shfmt
        sourcekit-lsp
        statix
        terraform
        terraform-ls
        tflint
        tfswitch
        tree-sitter
        typescript
        typescript-language-server
        typescript-go
        unstable.go
        unstable.gopls
        wireguard-tools
        yamllint
        yarn

        unstable.cue

        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = [ "wasm32-wasip1" ];
        })
      ] ++ cfg.additional-packages;
  };
}
