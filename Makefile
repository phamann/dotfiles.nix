.PHONY: update
update:
	nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command --flake ~/.config/nixpkgs

.PHONY: jetpac
jetpac:
	sudo home-manager switch --flake ~/.config/nixpkgs#phamann@jetpac

.PHONY: yoda
yoda:
	sudo home-manager switch --flake ~/.config/nixpkgs#phamann@yoda

.PHONY: x-wing
x-wing:
	sudo darwin-rebuild switch --flake ~/.config/nixpkgs#x-wing

.PHONY: r2-d2
r2-d2:
	sudo darwin-rebuild switch --flake ~/.config/nixpkgs#r2-d2
