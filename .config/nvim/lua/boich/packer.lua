
-- Bootstrap packer (https://github.com/wbthomason/packer.nvim#bootstrapping)
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    -- Core Plugins
    use 'wbthomason/packer.nvim'                    -- Plugin Manager
    use "nvim-lua/plenary.nvim"                     -- Set of lua functions

    -- UI Enhancements
    use {                                           -- Color Scheme
        'ellisonleao/gruvbox.nvim',
        config = function()
            vim.cmd('colorscheme gruvbox')
        end
    }

    -- Navigation & Searching
    use {                                           -- File & Directory searching
        'nvim-telescope/telescope.nvim',
        tag = '0.1.2',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {                                           -- Hotkey vertical and horizontal jumping to words
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            require'hop'.setup {
                keys = 'etovxqpdygfblzhckisuran'
            }
        end
    }
    use('theprimeagen/harpoon')                     -- Hotkeys for specific files

    -- Git & Version Control
    use('tpope/vim-fugitive')                       -- Git
    use('mbbill/undotree')                          -- Creates a git-like tree for undos

    -- Language Features & LSP
    use('nvim-treesitter/nvim-treesitter',          -- Syntax trees
        {run = ':TSUpdate'})
    use {                                           -- LSP
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        }
    }

    -- Misc
    use {                                           -- Leetcode coding problems
        "Dhanus3133/LeetBuddy.nvim",
        config = function()
            require('leetbuddy').setup({
                domain = "com",
                language = "java",
            })
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Ensure this is at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end

end)

