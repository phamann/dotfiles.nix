{ ... }:
{
  # Publish each home-manager module as a flake output. External consumers
  # (or a future NixOS+HM host inside this repo) can import any of them via
  #
  #   imports = [ inputs.<this-flake>.homeManagerModules.<name> ];
  #
  # `default` is the aggregator — pulls in every module, hosts then opt in
  # via `modules.<name>.enable = true`. The individual entries are for
  # consumers that want to cherry-pick.
  #
  # Some modules need extra inputs from extraSpecialArgs to evaluate:
  # - theme    requires `inputs.catppuccin`
  # - claude-code requires `inputs.claude-code-nix` and `system`
  # External consumers must wire those through their own HM specialArgs.
  flake.homeManagerModules = {
    default = ../modules;

    alacritty = ../modules/alacritty;
    bat = ../modules/bat;
    claude-code = ../modules/claude-code;
    direnv = ../modules/direnv;
    fzf = ../modules/fzf;
    ghostty = ../modules/ghostty;
    git = ../modules/git;
    gpg = ../modules/gpg;
    gui = ../modules/gui;
    kitty = ../modules/kitty;
    nvim = ../modules/nvim;
    opencode = ../modules/opencode;
    packages = ../modules/packages;
    ssh = ../modules/ssh;
    starship = ../modules/starship;
    theme = ../modules/theme;
    tmux = ../modules/tmux;
    zed = ../modules/zed;
    zellij = ../modules/zellij;
    zsh = ../modules/zsh;
  };
}
