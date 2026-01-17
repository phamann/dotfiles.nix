# Plan: Add Claude Code Module with Agenix Secret Management

## Overview

Add a new home-manager module for Claude Code configuration, using agenix to securely manage the MCP server API key.

## Files to Create/Modify

| File | Action |
|------|--------|
| `flake.nix` | Add agenix input |
| `secrets/secrets.nix` | Define SSH keys for decryption |
| `secrets/context7-api-key.age` | Encrypted API key |
| `modules/claude-code/default.nix` | New module |
| `modules/default.nix` | Import new module |
| `hosts/x-wing/home.nix` | Enable module |
| `hosts/r2-d2/home.nix` | Enable module |

## Implementation Steps

### Step 1: Add Agenix to Flake

Update `flake.nix` to include agenix:

```nix
inputs = {
  # ... existing inputs
  agenix.url = "github:ryantm/agenix";
  agenix.inputs.nixpkgs.follows = "nixpkgs";
};
```

Add module to darwin configurations:
```nix
modules = [
  agenix.darwinModules.default
  # ... existing modules
];
```

For home-manager (yoda), use `agenix.homeManagerModules.default`.

### Step 2: Create Secrets Directory

Create `secrets/secrets.nix` with your SSH public keys:

```nix
let
  phamann = "ssh-ed25519 AAAA..."; # from ~/.ssh/id_ed25519.pub
  x-wing = "ssh-ed25519 AAAA...";  # host key if needed
  r2-d2 = "ssh-ed25519 AAAA...";
in {
  "context7-api-key.age".publicKeys = [ phamann x-wing r2-d2 ];
}
```

### Step 3: Create Encrypted Secret

```bash
cd /Users/phamann/.config/nixpkgs/secrets
nix run github:ryantm/agenix -- -e context7-api-key.age
# Enter the API key when prompted
```

### Step 4: Create Claude Code Module

Create `modules/claude-code/default.nix`:

```nix
{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.claude-code;

  # Wrapper script to inject API key from decrypted secret
  context7Wrapper = pkgs.writeShellScript "context7-mcp" ''
    export UPSTASH_CONTEXT7_API_KEY="$(cat ${config.age.secrets.context7-api-key.path})"
    exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp "$@"
  '';
in {
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf cfg.enable {
    # Decrypt API key at activation time
    age.secrets.context7-api-key = {
      file = ../../secrets/context7-api-key.age;
    };

    programs.claude-code = {
      enable = true;

      settings = {
        awsAuthRefresh = "aws sso login --profile bedrock";
        env = {
          CLAUDE_CODE_USE_BEDROCK = "1";
          AWS_REGION = "eu-west-1";
          AWS_PROFILE = "bedrock";
          ANTHROPIC_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-opus-4-5-20251101-v1:0";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-opus-4-5-20251101-v1:0";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-sonnet-4-5-20250929-v1:0";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/eu.anthropic.claude-haiku-4-5-20251001-v1:0";
        };
        permissions = {
          allow = [
            "ReadFile"
            "Edit"
            "Bash(git add .)"
            "Bash(git commit -m:*)"
            "Bash(git diff:*)"
            "Bash(gh pr diff:*)"
            "Bash(gh pr view:*)"
            "Bash(gh pr list:*)"
            "Bash(curl:*)"
            "Bash(mvn:*)"
            "WebFetch"
            "Bash(go test:*)"
            "Bash(go run:*)"
            "Bash(make test:*)"
          ];
        };
        enabledPlugins = {
          "commit-commands@claude-code-plugins" = true;
          "typescript-lsp@claude-plugins-official" = true;
          "gopls-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
        };
      };

      # MCP servers - uses wrapper script to inject API key at runtime
      mcpServers = {
        context7 = {
          command = "${context7Wrapper}";
          args = [];
        };
      };

      # User memory/instructions
      memory.text = ''
        When creating git commit messages ALWAYS use conventional commit style: https://www.conventionalcommits.org/en/v1.0.0/#specification
        When creating pull requests in Github ALWAYS mark them in draft status
      '';
    };
  };
}
```

**Note on MCP secret handling:** The context7 MCP server expects the API key via command-line argument or environment variable. Since we can't embed secrets directly in the Nix store (it's world-readable), we use a wrapper script that:
1. Reads the decrypted secret from the agenix-managed path at runtime
2. Sets the `UPSTASH_CONTEXT7_API_KEY` environment variable
3. Launches the actual MCP server

This keeps the API key out of the Nix store while making it available when needed.

### Step 5: Update Module Imports

Add to `modules/default.nix`:

```nix
imports = [
  # ... existing imports
  ./claude-code
];
```

### Step 6: Enable in Host Configurations

Add to `hosts/x-wing/home.nix` and `hosts/r2-d2/home.nix`:

```nix
modules = {
  # ... existing modules
  claude-code.enable = true;
};
```

### Step 7: Configure Age Identity Paths

In each host's home.nix, ensure age knows where to find the SSH key:

```nix
age.identityPaths = [
  "${config.home.homeDirectory}/.ssh/id_ed25519"
];
```

## Settings Migration Summary

| Current Setting | Home-Manager Option |
|----------------|---------------------|
| `env.*` | `programs.claude-code.settings.env` |
| `permissions.allow` | `programs.claude-code.settings.permissions.allow` |
| `enabledPlugins` | `programs.claude-code.settings.enabledPlugins` |
| `mcpServers` | `programs.claude-code.mcpServers` |
| `~/.claude/CLAUDE.md` | `programs.claude-code.memory.text` |
| `awsAuthRefresh` | `programs.claude-code.settings.awsAuthRefresh` |

## Verification

1. Build without switching to check for errors:
   ```bash
   darwin-rebuild build --flake .#x-wing
   ```

2. Switch and verify:
   ```bash
   make x-wing
   ```

3. Check generated files:
   ```bash
   cat ~/.claude/settings.json
   cat ~/.claude/CLAUDE.md
   ```

4. Verify secret decryption:
   ```bash
   # The MCP server should work with the decrypted API key
   claude-code  # Test that context7 MCP server connects
   ```

## Notes

- The `enabledPlugins` setting may need manual plugin installation initially - plugins are tracked separately in `~/.claude/plugins/`
- Existing `~/.claude/settings.local.json` will be preserved for host-specific overrides not managed by home-manager
- The wrapper script approach for MCP secrets is robust but adds a layer of indirection
- Consider adding ghostty/kitty/alacritty module dependency if you want terminal integration with Claude Code
