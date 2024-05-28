return {
    -- Debugging things
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>bt", "<cmd>lua require('dap').toggle_breakpoint()<cr>", silent = true },
            { "<leader>bc", "<cmd>lua require('dap').continue()<cr>", silent = true },
            { "<leader>bo", "<cmd>lua require('dap').step_over()<cr>", silent = true },
            { "<leader>bi", "<cmd>lua require('dap').step_into()<cr>", silent = true },
            { "<leader>bu", "<cmd>lua require('dap').step_out()<cr>", silent = true },
        },
    },

    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        ft = "python",
        config = function()
            local dap_python = require("dap-python")
            dap_python.setup()
            dap_python.test_runner = "pytest"
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        keys = { { "<leader>og", "<cmd>lua require('dapui').toggle()<cr>", silent = true } },
        config = true,
    },
}
