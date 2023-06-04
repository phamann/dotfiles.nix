# ❄️ My Nix dotfiles

My multi-host, multi-arch, dotfiles powered by [nix](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager).

All configuration is defined in functionality/package-specific modules in the `modules` directory, and then hosts (i.e. machines) are configured in the `hosts` directory. Each host can optionally opt-in to modules, allowing me to have consistent configuration across machines while still having optional per-host configuration.

## Folder structure

- `hosts/`
  - Host specific configuration
- `modules/`
  - home-manager modules

## Common commands

```zsh
# Update the flake dependenices and lock file
% nix flake update
```

```zsh
# Rebuild the system
% home-manager switch --flake ~/.config/nixpkgs #phamann@yoda
```

## Inspiration

- [mccurdyc/nixos-config](https://github.com/mccurdyc/nixos-config)
