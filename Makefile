.PHONY: update
update:
	nix flake update --flake ~/.config/nixpkgs

.PHONY: jetpac
jetpac:
	home-manager switch --flake ~/.config/nixpkgs #phamann@jetpac

.PHONY: yoda
yoda:
	home-manager switch --flake ~/.config/nixpkgs #phamann@yoda

.PHONY: x-wing
x-wing:
	darwin-rebuild switch --impure --flake ~/.config/nixpkgs #phamann@x-wing

.PHONY:r2-d2
r2-d2:
	darwin-rebuild switch --impure --flake ~/.config/nixpkgs #phamann@r2-d2
