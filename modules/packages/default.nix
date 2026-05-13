{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.modules.packages;
in
{
  imports = [
    ./cli
    ./dev
    ./k8s
  ];

  options.modules.packages = {
    # Free-form escape hatch for genuinely host-unique packages. Phase 4
    # removes this option once profiles own host-specific additions via
    # `home.packages` directly.
    additional-packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Host-specific package additions. Removed in Phase 4.";
    };
  };

  config.home.packages = cfg.additional-packages;
}
