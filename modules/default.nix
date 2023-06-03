{ inputs
, pkgs
, config
, ...
}: {
  imports = [
    ./zsh
    ./fzf
    ./starship
    ./packages
    ./nvim
    ./git
    ./ssh
    ./tmux
    /*
    ./gpg
    ./direnv */
  ];
}
