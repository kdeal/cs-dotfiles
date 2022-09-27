require("neotest").setup({
  adapters = {
    require("neotest-python")({}),
    require('neotest-go'),
  },
})

-- Add background to the gutter icons
vim.cmd([[
  highlight! link NeotestPassed GruvboxGreenSign
  highlight! link NeotestFailed GruvboxRedSign
  highlight! link NeotestRunning GruvboxPurpleSign
  highlight! link NeotestSkipped GruvboxBlueSign
]])

nnoremap('<leader>op', ':lua require("neotest").summary.toggle()<cr>', { silent = true })

nnoremap('<leader>rt', ':lua require("neotest").run.run({strategy = "dap"})<cr>', { silent = true })
nnoremap('<leader>rf', ':lua require("neotest").run.run(vim.fn.expand("%"))<cr>', { silent = true })
