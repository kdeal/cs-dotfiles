return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        build = ":Copilot auth",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
        },
    },
    {
        "saghen/blink.cmp",

        version = "v0.*",
        dependencies = { "fang2hou/blink-copilot" },

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            appearance = {
                kind_icons = {
                    Copilot = "",
                },
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release
                use_nvim_cmp_as_default = true,
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
                list = {
                    selection = {
                        preselect = false,
                    },
                },
            },

            -- default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, via `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer", "dadbod", "lazydev", "copilot" },
                providers = {
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    -- dont show LuaLS require statements when lazydev has items
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", fallbacks = { "lsp" } },
                    copilot = {
                        name = "copilot",
                        module = "blink-copilot",
                        score_offset = 100,
                        async = true,
                    },
                },
            },

            signature = { enabled = true },
        },
    },
}
