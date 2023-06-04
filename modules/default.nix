{ inputs
, pkgs
, config
, ...
}: {
  imports = [
    ./zsh
    ./fzf
    ./kitty
    ./starship
    ./packages
    ./nvim
    ./git
    ./ssh
    ./tmux
    ./gpg
    ./direnv
  ];
}
