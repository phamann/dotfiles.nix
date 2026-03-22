# ❄️ My Nix dotfiles

My multi-host, multi-arch, dotfiles powered by [nix](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager).

All configuration is defined in functionality/package-specific modules in the `modules` directory, and then hosts (i.e. machines) are configured in the `hosts` directory. Each host can optionally opt-in to modules, allowing me to have consistent configuration across machines while still having optional per-host configuration.

## Documentation

- [New machine setup](docs/SETUP.md)

## Hosts

| Host   | Arch            | Type       |
|--------|-----------------|------------|
| x-wing | aarch64-darwin  | nix-darwin |
| r2-d2  | aarch64-darwin  | nix-darwin |
| yoda   | x86_64-linux    | home-manager only |

## Folder structure

- `docs/` — documentation
- `hosts/` — per-host configuration
- `modules/` — reusable home-manager modules
- `scripts/` — helper scripts

## Common commands

```zsh
# Update the flake dependencies and lock file
make update

# Rebuild for a specific host
make x-wing   # macOS (aarch64-darwin)
make r2-d2    # macOS (aarch64-darwin)
make yoda     # Linux (x86_64-linux)
```

## Inspiration

- [mccurdyc/nixos-config](https://github.com/mccurdyc/nixos-config)
