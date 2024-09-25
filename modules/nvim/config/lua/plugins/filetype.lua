--[[ return {
    "nathom/filetype.nvim",
    opts = {
        overrides = {
            extensions = {
                vcl = "vcl",
                hcl = "hcl",
                terraformrc = "hcl",
                tf = "terraform",
                tfvars = "terraform",
                tfstate = "json",
            },
            complex = {
                [".*.vcl.tmpl"] = "vcl",
                ["api.tpl"] = "vcl",
                ["kitty.conf"] = "kitty",
                ["*.tfstate.backup"] = "json",
                ["terraform.rc"] = "hcl",
                ["Dockerfile.*"] = "dockerfile",
            },
        }
    },
} ]]
