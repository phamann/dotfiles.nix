{ inputs
, pkgs
, config
, ...
}: {
  imports = [
    ./zsh
    ./starship
    /* ./git
    ./nvim
    ./ssh
    ./tmux
    ./gpg
    ./direnv

    ./home */
    ./packages
  ];
}
