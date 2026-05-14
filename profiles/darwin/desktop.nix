_: {
  # Every Mac host imports this; combines the system defaults
  # (./system.nix) with the shared homebrew config (./homebrew.nix).
  # Work-only additions live in ./work.nix which imports this profile.
  imports = [
    ./system.nix
    ./homebrew.nix
  ];
}
