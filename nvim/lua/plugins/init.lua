return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    opts = {
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "h", function()
          local node = api.tree.get_node_under_cursor()
          if node.parent and node.parent.name ~= ".." then
            api.node.navigate.parent_close()
          else
            api.tree.change_root_to_parent()
            vim.defer_fn(function() vim.cmd("normal! gg") end, 10)
          end
        end, { buffer = bufnr, desc = "Go to parent or cd up" })
        vim.keymap.set("n", "-", api.tree.collapse_all, { buffer = bufnr, desc = "Collapse all" })
        vim.keymap.set("n", "l", api.node.open.edit, { buffer = bufnr, desc = "Open/expand" })
        -- Enter: cd into folder (+ jump to top) or open file
        vim.keymap.set("n", "<CR>", function()
          local node = api.tree.get_node_under_cursor()
          if node.type == "directory" then
            api.tree.change_root_to_node()
            vim.defer_fn(function() vim.cmd("normal! gg") end, 10)
          else
            api.node.open.edit()
          end
        end, { buffer = bufnr, desc = "cd into directory or open file" })
      end,
    },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            vim.cmd("NvimTreeOpen")
          end
        end,
      })
    end,
  },

  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = { { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    opts = {
      outline_window = {
        position = "right",
      },
    },
  },
}
