{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        # Anchors the project root (treefmt finds files to format from here).
        projectRootFile = "flake.nix";

        # RFC 166 nixfmt — the official Nix formatter since nixfmt v1.0.0.
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
        };

        settings.global.excludes = [
          # Generated / vendored. Don't touch.
          "flake.lock"
          "*.lock"
          ".gitignore"
          # Plugin lock-files written by neovim's lazy.nvim.
          "modules/nvim/config/lazy-lock.json"
        ];
      };
    };
}
