local lsp = require('lsp-zero')
local lspconfig = require('lspconfig')
local lsp_util = require "lspconfig/util"

local function formatIfSupported()
    local supported_filetypes = { 'python', 'go', 'lua', 'rust', 'asm' }
    local current_filetype = vim.bo.filetype

    for _, supported_type in ipairs(supported_filetypes) do
        if current_filetype == supported_type then
            vim.cmd('LspZeroFormat')
            return
        end
    end
end



lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    vim.api.nvim_create_autocmd('BufWritePre', {
        callback = formatIfSupported

    })
end)

require('mason').setup({
    ensure_installed = { 'mypy', 'ruff', 'black', 'gofumpt', 'goimports-reviser', 'golines', 'asmfmt' },
})
require('mason-lspconfig').setup({
    ensure_installed = { 'pyright', 'rust_analyzer', 'gopls', 'lua_ls', 'dockerls', 'docker_compose_language_service', 'html' },
    handlers = {
        lsp.default_setup,
        rust_analyzer = function()
            lspconfig.rust_analyzer.setup({
                filetypes = { "rust" },
                root_dir = lsp_util.root_pattern("Cargo.toml"),
                settings = {
                    ['rust_analyzer'] = {
                        cargo = {
                            allFeatures = true,
                        }
                    }
                }
            })
            lspconfig.gopls.setup({
                filetypes = { "go", "gowork", "gomod", "gotmpl" },
                cmd = { "gopls" },
                root_dir = lsp_util.root_pattern("go.work", "go.mod", ".git"),
                settings = {
                    gopls = {
                        completeUnimported = true,
                        usePlaceholders = true,
                        analyses = {
                            unusedparams = true,
                        }
                    }
                }
            })
            lspconfig.pyright.setup({
                filetypes = { "python" },
            })
        end
    },
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})
