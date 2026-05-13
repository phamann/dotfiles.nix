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
yoda: ## Rebuild yoda (home-manager only, x86_64-linux)
	sudo home-manager switch --flake ~/.config/nixpkgs#phamann@yoda

.PHONY: jetpac
jetpac: ## Rebuild jetpac (legacy; flake target not currently defined)
	sudo home-manager switch --flake ~/.config/nixpkgs#phamann@jetpac

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
