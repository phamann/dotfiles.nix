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

    /* ./git
    ./nvim
    ./ssh
    ./tmux
    ./gpg
    ./direnv */
  ];
}
