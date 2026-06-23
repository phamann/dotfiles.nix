_: {
  imports = [
    ../../profiles/work-laptop.nix
    ../../modules/keyboard-remap
  ];

  # EVO75 external keyboard swaps ` and § at the HID level (see module).
  modules.keyboard-remap.enable = true;

  # modules.theme.scheme = "base24-catppuccin-frappe";
  # modules.theme.scheme = "base24-catppuccin-macchiato";
  # modules.theme.scheme = "base24-catppuccin-mocha";
  # modules.theme.scheme = "base24-tokyo-night-moon";
  # modules.theme.scheme = "base24-tomorrow-night";
  # modules.theme.scheme = "base24-later-this-evening"; ## *
  # modules.theme.scheme = "base24-space-gray-eighties-dull"; ## *
  # modules.theme.scheme = "base24-0x96f";
  # modules.theme.scheme = "base24-ayu-mirage"; ## *
  # modules.theme.scheme = "base24-mission-brogue";
  # modules.theme.scheme = "base16-ashes";
  # modules.theme.scheme = "base16-edge-dark"; ## *
  # modules.theme.scheme = "base16-ocean"; # # *
  # modules.theme.scheme = "base24-one-dark";
  # modules.theme.scheme = "base24-pnevma";
  # modules.theme.scheme = "base24-ocean"; # # *
  modules.theme.scheme = "base24-ocean-custom"; # # *
}
