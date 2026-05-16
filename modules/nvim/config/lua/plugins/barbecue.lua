return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  -- Pass an explicit theme so barbecue doesn't auto-capture Normal at
  -- setup time (which runs before Stylix applies base16-nvim's palette).
  -- Highlights are scheme-positional via vim.g.stylix_palette.
  opts = function()
    local p = vim.g.stylix_palette
    return {
      theme = {
        -- Bar fill matches the editor body.
        normal    = { bg = p.base00, fg = p.base05 },
        ellipsis  = { fg = p.base04 },
        separator = { fg = p.base04 },
        dirname   = { fg = p.base04 },
        basename  = { fg = p.base05, bold = true },
        modified  = { fg = p.base09 },
        context   = {},

        -- LSP symbol kinds → base24 slots, aligned to base16-nvim's
        -- treesitter mapping so breadcrumb colours match what you see in
        -- the buffer (e.g. a `namespace Foo` displays `Foo` in base08,
        -- not base0E — base16-nvim treats namespace identifiers as
        -- variable-like rather than keyword-like).
        context_file           = { fg = p.base0D }, -- @text.title / heading
        context_module         = { fg = p.base08 }, -- @namespace
        context_namespace      = { fg = p.base08 },
        context_package        = { fg = p.base08 },
        context_class          = { fg = p.base0A }, -- @type
        context_interface      = { fg = p.base0A },
        context_enum           = { fg = p.base0A },
        context_struct         = { fg = p.base0A },
        context_array          = { fg = p.base0A },
        context_object         = { fg = p.base0A },
        context_event          = { fg = p.base0A },
        context_type_parameter = { fg = p.base0A },
        context_method         = { fg = p.base0D }, -- @function / @method
        context_function       = { fg = p.base0D },
        context_constructor    = { fg = p.base0D },
        context_property       = { fg = p.base05 }, -- @property / @field
        context_field          = { fg = p.base05 },
        context_key            = { fg = p.base05 },
        context_variable       = { fg = p.base05 }, -- @variable (overridden to base05 in autocmds.lua)
        context_enum_member    = { fg = p.base09 }, -- @constant
        context_constant       = { fg = p.base09 },
        context_string         = { fg = p.base0B }, -- @string
        context_number         = { fg = p.base09 }, -- @number
        context_boolean        = { fg = p.base09 }, -- @boolean
        context_null           = { fg = p.base09 },
        context_operator       = { fg = p.base05 }, -- @operator
      },
    }
  end,
}
