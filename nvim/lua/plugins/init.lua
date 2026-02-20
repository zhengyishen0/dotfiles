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
    config = function()
      local wanted = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "python",
        "javascript", "typescript", "tsx",
        "json",
        "bash",
        "nu",
      }
      local installed = require("nvim-treesitter").get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, wanted)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end
      -- Use bash parser for zsh files
      vim.treesitter.language.register("bash", "zsh")
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
      {
        "b0o/nvim-tree-preview.lua",
        opts = {
          max_width = 120,
          max_height = 40,
          win_position = {
            row = function()
              return math.floor((vim.o.lines - 40) / 4)  -- higher
            end,
            col = function()
              return math.floor((vim.o.columns - 100) / 2)
            end,
          },
        },
      },
    },
    opts = function()
      local submodule_icon = "@"
      local submodule_color = "#c678dd"  -- teal

      return {
        view = { width = 35 },
        filesystem_watchers = { enable = true },
        filters = { dotfiles = true, git_ignored = false },
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
        -- Auto-preview files (not folders) on cursor move
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = bufnr,
          callback = function()
            local node = api.tree.get_node_under_cursor()
            if node and node.type ~= "directory" then
              preview.node(node)
            else
              preview.unwatch()  -- close preview on folders
            end
          end,
        })
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
        vim.keymap.set("n", "q", preview.unwatch, { buffer = bufnr, desc = "Close preview" })
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
    "stevearc/aerial.nvim",
    event = { "LspAttach", "BufReadPost" },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
      layout = {
        default_direction = "right",
        placement = "edge",
        width = 35,
        preserve_equality = false,
      },
      filter_kind = false,
      show_guides = true,
      autojump = true,
    },
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function(_, opts)
      require("aerial").setup(opts)
      require("telescope").load_extension("aerial")

      local function open_aerial()
        vim.defer_fn(function()
          if not require("aerial").is_open() then
            pcall(require("aerial").open, { focus = false })
          end
        end, 200)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function() open_aerial() end,
      })
      open_aerial()
    end,
  },
}
