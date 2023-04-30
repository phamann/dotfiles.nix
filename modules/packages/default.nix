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
        bat
        cachix
        cargo
        dig
        docker
        docker-compose
        fd
        fzf
        gcc
        git-crypt
        gnumake
        go
        gofumpt
        google-cloud-sdk
        gopls
        htop
        jq
        nodejs
        ripgrep
        rnix-lsp
        rustfmt
        starship
        terraform
        tfswitch
        tmux
        tree
      ]
      ++ cfg.additional-packages;
  };
}
