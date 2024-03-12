.PHONY: update
update:
	nix flake update ~/.config/nixpkgs

.PHONY: yoda
yoda:
	home-manager switch --flake ~/.config/nixpkgs #phamann@yoda

.PHONY: x-wing
x-wing:
	darwin-rebuild switch --impure --flake ~/.config/nixpkgs #phamann@x-wing
