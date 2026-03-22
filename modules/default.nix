{ inputs, pkgs, config, ... }: {
  imports = [
    ./alacritty
    ./bat
    ./claude-code
    ./direnv
    ./fzf
    ./ghostty
    ./git
    ./gpg
    ./gui
    ./kitty
    ./nvim
    ./opencode
    ./packages
    ./ssh
    ./starship
    ./tmux
    ./zed
    ./zellij
    ./zsh
  ];
}
