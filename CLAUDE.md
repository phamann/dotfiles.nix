# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based dotfiles repository for managing multi-host, multi-arch system configurations using nix-darwin (macOS) and home-manager.

## Common Commands

```bash
# Update flake dependencies and lock file
make update
# or: nix flake update

# Rebuild for specific hosts (use the host you're on):
make x-wing    # macOS (aarch64-darwin) - uses darwin-rebuild
make r2-d2     # macOS (aarch64-darwin) - uses darwin-rebuild
make yoda      # Linux (x86_64-linux) - uses home-manager
```

## Architecture

**Flake Inputs (flake.nix):**
- `nixpkgs`: Stable channel (25.11-darwin)
- `nixpkgs-unstable`: Unstable channel (available as `pkgs.unstable.*`)
- `darwin`: nix-darwin for macOS system configuration
- `home-manager`: User environment management
- `rust-overlay`: Rust toolchain management

**Host Types:**
- **Darwin hosts** (x-wing, r2-d2): Use `darwin-rebuild switch` and have both `configuration.nix` (system-level: macOS defaults, homebrew casks, system services) and `home.nix` (user-level)
- **Home-manager only hosts** (yoda): Use `home-manager switch` with just `home.nix`

**Module Pattern:**
Each module in `modules/` follows this structure:
```nix
{ pkgs, lib, config, ... }:
{
  options.modules.<name> = { enable = mkEnableOption "<name>"; };
  config = mkIf cfg.enable { ... };
}
```

Hosts opt-in to modules via `modules.<name>.enable = true` in their `home.nix`. The `modules/packages/default.nix` module also supports `modules.packages.additional-packages` for host-specific packages.

**Key Directories:**
- `hosts/<hostname>/` - Per-host configuration (home.nix, configuration.nix for darwin)
- `modules/` - Reusable home-manager modules with opt-in pattern
- `scripts/` - Helper scripts (e.g., aliasApplications.nix for macOS app aliasing)
