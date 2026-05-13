{ ... }:
{
  # Aggregator: importing this brings in cli/dev/k8s sub-modules. Each
  # exposes its own `modules.packages.<name>.enable`. There is no
  # top-level `modules.packages.enable` — hosts/profiles toggle the
  # sub-modules individually.
  imports = [
    ./cli
    ./dev
    ./k8s
  ];
}
