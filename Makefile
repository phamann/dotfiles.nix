.DEFAULT_GOAL := help

# Host rebuild targets — switch the running system / user environment to
# the flake config for that host. Use the target matching the machine
# you're on.

.PHONY: x-wing
x-wing: ## Rebuild x-wing (personal Mac, aarch64-darwin)
	sudo darwin-rebuild switch --flake ~/.config/nixpkgs#x-wing

.PHONY: r2-d2
r2-d2: ## Rebuild r2-d2 (work Mac, aarch64-darwin)
	sudo darwin-rebuild switch --flake ~/.config/nixpkgs#r2-d2

.PHONY: yoda
yoda: ## Rebuild yoda (NixOS, x86_64-linux) — run ON yoda
	sudo nixos-rebuild switch --flake ~/.config/nixpkgs#yoda

# Build happens ON yoda: an aarch64-darwin Mac cannot build x86_64-linux
# derivations, and nix-darwin's linux-builder only provides aarch64-linux.
.PHONY: yoda-remote
yoda-remote: ## Rebuild yoda from a Mac, building on yoda itself
	nixos-rebuild switch --flake ~/.config/nixpkgs#yoda \
		--target-host phamann@192.168.1.40 \
		--build-host phamann@192.168.1.40 \
		--sudo

# Flake hygiene.

.PHONY: update
update: ## Update flake.lock to the latest input revs
	nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command --flake ~/.config/nixpkgs

.PHONY: fmt
fmt: ## Format all .nix files (nixfmt-rfc-style via treefmt)
	nix fmt

.PHONY: check
check: ## Run nix flake check (eval all hosts + treefmt + pre-commit)
	nix flake check

.PHONY: help
help: ## Show this help (default target)
	@awk 'BEGIN { FS = ":.*?## "; printf "Targets:\n" } /^[a-zA-Z0-9_-]+:.*?## / { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
