local install_path = vim.fn.stdpath('data') ..'/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Colorscheme
    use 'morhetz/gruvbox'

    -- Easy commenting in any language
    use 'tpope/vim-commentary'

    -- Shortcuts for next and previous <quickfix|location>
    use 'tpope/vim-unimpaired'

    -- Git in vim
    use {
        'tpope/vim-fugitive',
        config = function() require('fugitive_conf') end,
    }

    -- Repeat stuff
    use 'tpope/vim-repeat'

    -- Adds vim commands that wrap common file operations
    use {
        'tpope/vim-eunuch',
        cmd = { 'Delete', 'Unlink', 'Move', 'Rename', 'Chmod', 'Mkdir', 'SudoWrite', 'SudoEdit' },
    }

    -- Automatically figure out indentation
    use 'tpope/vim-sleuth'

    -- Set the cwd to repo root
    use 'airblade/vim-rooter'

    -- Undo tree viewer
    use { 'mbbill/undotree', cmd = 'UndotreeToggle' }

    -- Show how far indented a line is
    use 'Yggdroot/indentLine'

    -- Fuzzy finding all the things
    use { 'junegunn/fzf', run = './install --all --no-zsh --no-bash' }

    -- Syntax and highlighting for languages
    use {
        'sheerun/vim-polyglot',
        setup = function()
            -- Disable polyglot python since I read built in python is actually good
            -- This has to be set before polyglot is loaded
            vim.g.polyglot_disabled = { 'python' }
        end,
    }
    use 'Vimjas/vim-python-pep8-indent'
    use 'raimon49/requirements.txt.vim'

    -- Visual made * and # search
    use 'bronson/vim-visual-star-search'

    -- Move function argument left or right
    use {
        'AndrewRadev/sideways.vim',
        cmd = { 'SidewaysLeft', 'SidewaysRight' },
    }
    -- Join or split things (lists, function line, tuples)
    use 'AndrewRadev/splitjoin.vim'

    -- Config for neovim language servers
    use { 'neovim/nvim-lspconfig', config = function() require('lsp_conf') end }

    -- Shows language server progress
    use { 'j-hui/fidget.nvim', config = function() require('fidget_conf') end }

    -- Hook commands up to nvim lsp
    use {
        'jose-elias-alvarez/null-ls.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function() require('null_ls_conf') end,
    }

    -- Lua helper library
    use 'nvim-lua/plenary.nvim'

    -- Lua Fuzzy Finder
    use { 'nvim-telescope/telescope.nvim', config = function() require('telescope_conf') end }

    -- FZF like filtering for telescope
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    -- Lua completion tool
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use { 'hrsh7th/nvim-cmp', config = function() require('cmp_conf') end }

    -- Simplifies the Vim ui to help you to focus on writing
    use 'junegunn/goyo.vim'

    -- Javascript stuff
    use 'pangloss/vim-javascript'

    -- Tree sitter based syntax highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function() require('treesitter_conf') end,
    }

    -- Automatically set up configuration after cloning packer.nvim
    if packer_bootstrap then
        require('packer').sync()
    end
end)
