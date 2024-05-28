return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePre" },
        init = function()
            require("lint").linters_by_ft = {
                fish = { "fish", "cspell" },
                javascript = { "eslint", "cspell" },
                lua = { "cspell" },
                markdown = { "vale", "cspell" },
                python = { "ruff", "mypy", "cspell" },
                rust = { "cspell" },
                yaml = { "yamllint" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function(ev)
                    local lint = require("lint")
                    local linters = lint._resolve_linter_by_ft(vim.bo.filetype)
                    local progress = require("fidget.progress")
                    local linter_handles = {}
                    for _, linter_name in pairs(linters) do
                        local handle = progress.handle.create({
                            title = linter_name,
                            lsp_client = { name = "nvim-lint" },
                            percentage = 0,
                        })
                        linter_handles[linter_name] = handle
                    end
                    lint.try_lint(linters)
                    local timer = vim.loop.new_timer()
                    timer:start(100, 100, function()
                        local running = lint.get_running(ev.buf)
                        for linter_name, lint_handle in pairs(linter_handles) do
                            local found = false
                            for _, running_name in pairs(running) do
                                if linter_name == running_name then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                lint_handle:finish()
                                linter_handles[linter_name] = nil
                            end
                        end
                        if next(linter_handles) == nil then
                            timer:close()
                        end
                    end)
                end,
            })
        end,
    },
}
