
local lsp = require('lsp-zero') -- :Mason / :MasonLog

-- Set LSP defaults
lsp.preset('recommended')
vim.lsp.set_log_level("debug")

-- Install Servers
-- Server Name Reference: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
lsp.ensure_installed({
	'eslint',               -- ESLint
	'tsserver',             -- Typescript
    'lua_ls',               -- Lua
    'java_language_server', -- Java

})

-- Ensure vim-like navigation in LSP menus
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
	['<CR>'] = cmp.mapping.confirm({select = true}),
	['<C-Space>'] = cmp.mapping.complete(),
})
lsp.setup_nvim_cmp({mapping = cmp_mappings})

-- Set LSP Preferences
lsp.set_preferences({sign_icons = { }})

-- Define Global LSP Keymaps
lsp.on_attach(function(_, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    -- C-h is backspace in insert mode by default
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

end)

-- Lua specific config
require('lspconfig').lua_ls.setup(
  lsp.nvim_lua_ls({
    settings = {
      Lua = {
        diagnostics = {
          globals = {"vim"}
        }
      }
    },
    on_attach = function(_, bufnr)
      lsp.default_keymaps({buffer = bufnr})
    end
  })
)

-- Final Setup Call
lsp.setup()

