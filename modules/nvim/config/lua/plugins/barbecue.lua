return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons", -- optional dependency
  },
  -- No explicit theme — barbecue auto-derives from current highlights
  -- (Stylix's mini.base16 sets them).
  opts = { },
}
