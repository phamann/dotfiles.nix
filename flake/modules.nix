_: {
  # Publish each home-manager module as a flake output. External consumers
  # (or a future NixOS+HM host inside this repo) can import any of them via
  #
  #   imports = [ inputs.<this-flake>.homeManagerModules.<name> ];
  #
  # No `default` aggregator — Phase 4 made profiles the entrypoint
  # (profiles/{base,dev-laptop,work-laptop,headless-server}.nix) and the
  # old modules/default.nix was deleted.
  #
  # Some modules need extra inputs from extraSpecialArgs to evaluate:
  # - theme       requires `inputs.stylix` and `inputs.tinted-schemes`
  # - claude-code requires `inputs.claude-code-nix` and `system`
  # External consumers must wire those through their own HM specialArgs.
  flake.homeManagerModules = {
    bat = ../modules/bat;
    claude-code = ../modules/claude-code;
    direnv = ../modules/direnv;
    fzf = ../modules/fzf;
    ghostty = ../modules/ghostty;
    git = ../modules/git;
    gpg = ../modules/gpg;
    nvim = ../modules/nvim;
    opencode = ../modules/opencode;
    packages = ../modules/packages;
    ssh = ../modules/ssh;
    starship = ../modules/starship;
    theme = ../modules/theme;
    zed = ../modules/zed;
    zellij = ../modules/zellij;
    zsh = ../modules/zsh;
  };
}
