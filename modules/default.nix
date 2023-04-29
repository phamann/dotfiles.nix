{ inputs
, pkgs
, config
, ...
}: {
  home.stateVersion = "22.11";
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
