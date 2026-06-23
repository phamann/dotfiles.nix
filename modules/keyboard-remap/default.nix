{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.keyboard-remap;

  # USB identifiers for the EVO75 mechanical keyboard.
  matching = ''{"VendorID":0x36b0,"ProductID":0x311e}'';

  # The EVO75 reports the grave/tilde key (HID usage 0x35) and the ISO
  # "non-US \\" / § key (HID usage 0x64) the wrong way round on macOS. Swap
  # them so the legends match what is typed.
  mapping = builtins.concatStringsSep "" [
    ''{"UserKeyMapping":[''
    ''{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064},''
    ''{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}''
    "]}"
  ];
in
{
  options.modules.keyboard-remap = {
    enable = mkEnableOption "EVO75 hidutil key remapping (swap ` and §)";
  };

  config = mkIf cfg.enable {
    # hidutil mappings live in the running HID session and are wiped on
    # logout/reboot, so re-apply them at login via a launchd agent. RunAtLoad
    # fires once when the agent is bootstrapped at login; the keyboard must be
    # connected at that point for the match to take effect.
    launchd.agents.evo75-keymap = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/hidutil"
          "property"
          "--matching"
          matching
          "--set"
          mapping
        ];
        RunAtLoad = true;
        # Surfaced for debugging the (finicky) login-time device match.
        StandardErrorPath = "/tmp/evo75-keymap.err.log";
        StandardOutPath = "/tmp/evo75-keymap.out.log";
      };
    };
  };
}
