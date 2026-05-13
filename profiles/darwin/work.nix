_: {
  # incident.io work Mac system config. Adds work-specific homebrew and
  # the postgresql@17 PATH entry on top of the shared desktop profile.
  imports = [ ./desktop.nix ];

  homebrew = {
    casks = [
      "cursor"
      "expo-orbit"
      "gram"
      "granola"
      "linear"
      "loom"
      "postico"
      "slack"
      "zoom"
    ];
    brews = [
      "postgresql@17"
      "redis"
      "memcached"
    ];
  };

  environment.systemPath = [
    "/opt/homebrew/opt/postgresql@17/bin"
  ];
}
