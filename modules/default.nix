{ inputs
, pkgs
, config
, ...
}: {
  imports = [
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
    ./zellij
    ./zsh
  ];
}
