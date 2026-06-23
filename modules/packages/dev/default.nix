{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.dev;
in
{
  options.modules.packages.dev.enable =
    mkEnableOption "language toolchains, LSPs, linters, formatters, build tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # docker
      docker_29
      docker-compose

      # node / typescript
      bun
      eas-cli
      nodejs_22
      fixjson
      typescript
      typescript-go
      typescript-language-server
      yarn

      # go
      gofumpt
      goimports-reviser
      gotools
      unstable.go
      unstable.gopls

      # rust
      cargo-nextest
      rust-analyzer
      (rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
        targets = [ "wasm32-wasip1" ];
      })

      # python
      python313

      # lua
      lua
      lua54Packages.luacheck
      luaformatter

      # java
      maven

      # swift
      sourcekit-lsp

      # nix
      nil
      nixd
      nixfmt-rfc-style
      statix

      # cloud CLIs
      awscli2
      unstable.fastly
      (google-cloud-sdk.withExtraComponents (
        with google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))

      # terraform / infra
      terraform
      terraform-ls
      tflint
      tfswitch

      # diagrams
      d2
      graphviz

      # generic build tools / formatters / scanners
      gcc
      gnumake
      hadolint
      lld
      openssl
      pkg-config
      semgrep
      shfmt
      tree-sitter
      yamllint

      unstable.cue
    ];
  };
}
