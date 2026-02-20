return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      autopairs.setup({})

      -- Markdown: ** for bold (only after space or start of line)
      autopairs.add_rule(Rule("**", "**", "markdown")
        :with_pair(cond.before_regex("%s"))
        :with_move(cond.after_text("**")))
      autopairs.add_rule(Rule("**", "**", "markdown")
        :with_pair(cond.before_regex("^"))
        :with_move(cond.after_text("**")))

      -- Markdown: ~~ for strikethrough
      autopairs.add_rule(Rule("~~", "~~", "markdown")
        :with_pair(cond.before_regex("%s"))
        :with_move(cond.after_text("~~")))
      autopairs.add_rule(Rule("~~", "~~", "markdown")
        :with_pair(cond.before_regex("^"))
        :with_move(cond.after_text("~~")))
    end,
  },

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

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP
        "basedpyright",
        "typescript-language-server",
        "json-lsp",
        "bash-language-server",
        "marksman",
        "yaml-language-server",
        -- Formatters
        "prettier",
        "ruff",
        "stylua",
      },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "python",
        "javascript", "typescript", "tsx",
        "json", "jsonc",
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "b0o/nvim-tree-preview.lua" },
    opts = function()
      local submodule_icon = "@"
      local submodule_color = "#c678dd"  -- teal

      return {
        view = { width = 35 },
        filesystem_watchers = { enable = true },
        filters = { dotfiles = true },
        renderer = {
          highlight_git = "name",
          decorators = {
            "Git", "Open", "Hidden", "Modified", "Bookmark",
            "Diagnostics", "Copied", "Cut",
            require("nvim-tree-submodule").setup(submodule_icon, submodule_color),
          },
          icons = {
            glyphs = {
              git = {
                unstaged = "!",
                staged = "+",
                untracked = "?",
                deleted = "x",
                renamed = "→",
                unmerged = "‼",
                ignored = ",",
              },
            },
          },
        },
        on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "h", function()
          local node = api.tree.get_node_under_cursor()
          -- If expanded folder, collapse it first
          if node.type == "directory" and node.open then
            api.node.open.edit()
          -- If has parent in tree, go to parent
          elseif node.parent and node.parent.name ~= ".." then
            api.node.navigate.parent_close()
          -- At root, cd to parent directory and focus on previous root
          else
            local prev_root_path = api.tree.get_nodes().absolute_path
            api.tree.change_root_to_parent()
            vim.defer_fn(function()
              api.tree.find_file(prev_root_path)
            end, 10)
          end
        end, { buffer = bufnr, desc = "Collapse/parent/cd up" })
        vim.keymap.set("n", "-", api.tree.collapse_all, { buffer = bufnr, desc = "Collapse all" })
        local preview = require("nvim-tree-preview")
        vim.keymap.set("n", "l", function()
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          if node.type == "directory" then
            if not node.open then
              api.node.open.edit()  -- expand
            end
            vim.cmd("normal! j")  -- move to first child
          else
            preview.node(node)  -- preview file, cursor stays in tree
          end
        end, { buffer = bufnr, desc = "Preview/expand + go to child" })
        vim.keymap.set("n", "<Esc>", preview.unwatch, { buffer = bufnr, desc = "Close preview" })
        vim.keymap.set("n", "R", api.tree.reload, { buffer = bufnr, desc = "Refresh" })
        vim.keymap.set("n", "?", api.tree.toggle_help, { buffer = bufnr, desc = "Help" })
        vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, { buffer = bufnr, desc = "Toggle dotfiles" })
        vim.keymap.set("n", ",", api.tree.toggle_gitignore_filter, { buffer = bufnr, desc = "Toggle gitignore" })
        -- Enter: cd into folder (+ jump to top) or open file
        vim.keymap.set("n", "<CR>", function()
          local node = api.tree.get_node_under_cursor()
          if node.type == "directory" then
            api.tree.change_root_to_node()
            vim.defer_fn(function()
              if vim.bo.filetype == "NvimTree" then
                vim.cmd("normal! gg")
              end
            end, 10)
          else
            api.node.open.edit()
          end
        end, { buffer = bufnr, desc = "cd into directory or open file" })
      end,
      }
    end,
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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    },
  },

  {
    "gaoDean/autolist.nvim",
    ft = "markdown",
    opts = {},
    config = function(_, opts)
      require("autolist").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", { buffer = buf })
        end,
      })
    end,
  },

  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    event = "LspAttach",
    -- Ctrl+o mapped in mappings.lua
    opts = {
      outline_window = {
        split_command = "belowright 35vs",  -- Split relative to editor, not full height
        auto_resize = false,
        auto_jump = true,
      },
    },
    config = function(_, opts)
      local outline = require("outline")
      outline.setup(opts)

      local function open_outline()
        vim.defer_fn(function()
          -- Reopen outline
          if outline.is_open() then
            pcall(outline.close)
          end
          pcall(outline.open, { focus_outline = false })
        end, 200)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function() open_outline() end,
      })

      -- Handle the initial LspAttach that triggered plugin load
      open_outline()
    end,
  },
}
