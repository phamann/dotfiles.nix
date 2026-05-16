-- Barbecue's default theme (`theme = "auto"`) derives colours from active
-- highlight groups (Normal, Function, Type, Identifier, …). tinted-vim
-- defines all of those in line with scheme intent, so we don't override
-- anything here — barbecue's ColorScheme synchronizer keeps it aligned.
return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
}
