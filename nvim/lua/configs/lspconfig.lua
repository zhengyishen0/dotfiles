require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "bashls", "basedpyright", "ts_ls", "jsonls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
