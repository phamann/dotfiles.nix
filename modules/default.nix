{ inputs
, pkgs
, config
, ...
}: {
  imports = [
    ./alacritty
    ./bat
    ./direnv
    ./fzf
    ./git
    ./gpg
    ./gui
    ./kitty
    ./nvim
    ./packages
    ./ssh
    ./starship
    ./tmux
    ./zed
    ./zellij
    ./zsh
  ];
}
