require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "bashls", "basedpyright", "ts_ls", "jsonls", "marksman", "yamlls" }
vim.lsp.enable(servers)

-- Extend bashls to also attach to zsh files
vim.lsp.config("bashls", {
  filetypes = { "sh", "bash", "zsh" },
})

-- Nushell LSP (built-in, no mason package needed)
vim.lsp.config("nushell", {
  cmd = { "nu", "--lsp" },
  filetypes = { "nu" },
  root_markers = { ".git" },
})
vim.lsp.enable("nushell")
