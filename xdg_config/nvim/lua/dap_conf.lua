nnoremap('<leader>bt', ':lua require("dap").toggle_breakpoint()<cr>', { silent = true })

nnoremap('<leader>bc', ':lua require("dap").continue()<cr>', { silent = true })
nnoremap('<leader>bo', ':lua require("dap").step_over()<cr>', { silent = true })
nnoremap('<leader>bi', ':lua require("dap").step_into()<cr>', { silent = true })
nnoremap('<leader>bu', ':lua require("dap").step_out()<cr>', { silent = true })
