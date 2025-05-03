return {
    {
        "saghen/blink.cmp",

        version = "1.*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            appearance = {
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
                default = { "lsp", "path", "snippets", "buffer", "dadbod", "lazydev" },
                providers = {
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    -- dont show LuaLS require statements when lazydev has items
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", fallbacks = { "lsp" } },
                },
            },

            signature = { enabled = true },
        },
    },
}
