{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.gpg;
in
{
  options.modules.gpg = { enable = mkEnableOption "gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      enableSshSupport = true;
      extraConfig = ''
        pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
      '';
    };
  };
}
