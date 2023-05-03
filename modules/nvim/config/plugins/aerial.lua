return {
  'stevearc/aerial.nvim',
  opts = {
      layout = {
        default_direction = "prefer_left",
      },
  },
  keys = {
    { '<leader>a', '<cmd>AerialToggle!<CR>', desc = "Toggle aerial code view" },
  },
}
