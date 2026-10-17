_: {
  # Headless / SSH-only role for a dev box: base shell tooling plus
  # language toolchains and k8s tooling — nothing GUI, no laptop
  # conveniences. yoda is the only host using this today.
  imports = [
    ./base.nix
    ../modules/zellij
  ];

  modules = {
    # The zsh initContent auto-attaches to a `work` session on non-Darwin
    # hosts, which is this role — so zellij has to actually be installed
    # here. compact-bottom keeps the status bar out of the way over SSH.
    zellij = {
      enable = true;
      layout = "compact-bottom";
    };

    packages = {
      dev.enable = true;
      k8s.enable = true;
    };
  };
}
