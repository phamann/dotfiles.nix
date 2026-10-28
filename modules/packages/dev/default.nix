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
      # Build dependency for nvim's peek.nvim (`deno task build:fast`), which
      # otherwise fails its lazy.nvim build step silently.
      deno
      eas-cli
      nodejs_22
      # typescript-go ships both `tsgo` and a `tsc` alias; the latter collides
      # with classic typescript's `tsc` in home-manager's buildEnv. lowPrio on
      # classic typescript lets typescript-go win `tsc` (the native compiler),
      # while classic's `tsserver` (no collision) stays on PATH for the LSP.
      (lib.lowPrio typescript)
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

      # java
      maven

      # swift
      sourcekit-lsp

      # nix
      nixd
      nixfmt
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
      # 0.9.0 bundles the TALA layout engine (`d2 --layout=tala`), which
      # replaces the archived terrastruct/tap tala brew. Stable is still
      # 0.7.1, which predates the bundling — drop back to `d2` once stable
      # catches up.
      unstable.d2
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

      # Config/data languages. go-jsonnet is the maintained Go rewrite and
      # the binary set the jsonnet ecosystem (tanka, grizzly, mixins) expects;
      # it provides `jsonnetfmt`, `jsonnet`, `jsonnet-lint` and `jsonnet-deps`.
      # Do NOT also add `pkgs.jsonnet` (the older C++ build) — it ships the
      # same binary names and collides in home-manager's buildEnv.
      go-jsonnet
    ];
  };
}
