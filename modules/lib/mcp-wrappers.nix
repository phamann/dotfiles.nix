{ pkgs }:
{
  # Wraps the context7 MCP server so its API key is fetched from 1Password
  # at launch (not stored in the Nix store, not exported to user shells).
  # Imported by both modules/claude-code and modules/opencode.
  context7 = pkgs.writeShellScript "context7-mcp" ''
    export UPSTASH_CONTEXT7_API_KEY="$(${pkgs._1password-cli}/bin/op read 'op://Private/context7-api-token/password')"
    exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp "$@"
  '';
}
