{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.modules.nix;

  # Unauthenticated flake fetches share GitHub's 60 req/hr IP budget, which a
  # single `nix flake update` exhausts behind office NAT. The token is kept out
  # of the nix store -- everything there is world-readable -- so nix.conf only
  # carries an include and the secret is written at activation time.
  tokenFile = "${config.home.homeDirectory}/.config/nix/access-tokens.conf";
in
{
  options.modules.nix = {
    enable = mkEnableOption "nix";

    githubTokenRef = mkOption {
      type = types.str;
      default = "op://Private/github-nix-token/password";
      example = "op://Private/github-pat/password";
      description = ''
        1Password secret reference for the token nix presents to the GitHub
        API. It exists only to lift the rate limit from 60 to 5000 req/hr, so
        a token with no permissions whatsoever is enough; grant Contents:Read
        only if a private repo is ever added as a flake input.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Determinate Nix owns /etc/nix/nix.conf (hence `nix.enable = false` in
    # profiles/darwin/system.nix), so per-user config is the only writable
    # layer. `!include` is the optional form: a missing token file leaves nix
    # unauthenticated rather than erroring, which keeps a fresh host bootable.
    xdg.configFile."nix/nix.conf".text = ''
      !include ${tokenFile}
    '';

    # nix-darwin runs this via `launchctl asuser ... sudo -u phamann`, i.e.
    # inside the GUI session, which is the only context where op can reach the
    # 1Password desktop app to unlock. A locked vault is non-fatal: we leave
    # the token unset and nix falls back to unauthenticated requests.
    home.activation.nixAccessTokens = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      token="$(${pkgs._1password-cli}/bin/op read '${cfg.githubTokenRef}' 2>/dev/null || true)"
      if [ -n "$token" ]; then
        # Subshell umask so the file is never briefly world-readable.
        ( umask 077; printf 'extra-access-tokens = github.com=%s\n' "$token" > "${tokenFile}" )
      else
        verboseEcho "1Password unavailable; leaving nix access-tokens unset"
      fi
    '';
  };
}
