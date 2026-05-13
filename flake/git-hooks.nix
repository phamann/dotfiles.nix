{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit = {
        # Adds pre-commit-hooks to flake.checks so `nix flake check` enforces.
        check.enable = true;

        settings.hooks = {
          # Delegate Nix formatting to treefmt — single source of truth with
          # `nix fmt`. Uses the same treefmt build, same nixfmt-rfc-style,
          # same exclude list (see flake/treefmt.nix).
          treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };

          # Anti-pattern linter for Nix. Pin to nixpkgs's statix to pick up
          # newer rule semantics — older bundled versions flag the canonical
          # `cfg = config.modules.<name>;` module-alias idiom as W04 (false
          # positive that's been refined in recent releases). .statix.toml
          # disables manual_inherit repo-wide as belt-and-braces.
          statix = {
            enable = true;
            package = pkgs.statix;
          };

          # Dead-code linter for Nix.
          deadnix.enable = true;
        };
      };

      # NOTE: NOT extending devShells.default.shellHook with `pre-commit
      # install`. Patrick's git config sets `core.hooksPath = ~/.git-hooks`
      # globally, which would cause `pre-commit install` to write into that
      # shared directory — affecting every git repo on the machine, not
      # just this one. Hooks run via `nix flake check` instead, plus CI
      # (Phase 5).
      #
      # If you want per-commit enforcement locally:
      #   1. Unset core.hooksPath for THIS repo only:
      #        git config --local --unset core.hooksPath
      #   2. Then from inside `nix develop`:
      #        pre-commit install
    };
}
