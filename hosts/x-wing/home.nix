{ ... }:
{
  imports = [
    ../../profiles/dev-laptop.nix
    ../../modules/alacritty
  ];

  modules = {
    alacritty.enable = true;
    theme.flavour = "frappe";
  };
}
