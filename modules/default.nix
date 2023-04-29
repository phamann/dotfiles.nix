{ inputs
, pkgs
, config
, ...
}: {
  imports = [
    ./zsh
    /* ./git
    ./nvim
    ./ssh
    ./tmux
    ./gpg
    ./direnv

    ./home
    ./packages */
  ];
}
