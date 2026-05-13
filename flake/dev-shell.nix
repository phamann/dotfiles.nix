{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixpkgs-dev";

        # Everything you need to work on this repo from a fresh clone,
        # without relying on the user's profile. Same tools also live in
        # modules/packages/dev so the user's editor (zed format-on-save,
        # nvim LSP) has them available outside `nix develop`. Duplication
        # is free — same store paths.
        packages = with pkgs; [
          nixd # nix LSP
          nixfmt-rfc-style # RFC 166 formatter
          statix # anti-pattern linter
          deadnix # dead-code linter
        ];
      };
    };
}
