return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    init = function()
      vim.g.smart_splits_multiplexer_integration = 'wezterm'
    end,
    opts = {},
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, mode = { "n", "t" }, desc = "Navigate left" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, mode = { "n", "t" }, desc = "Navigate down" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, mode = { "n", "t" }, desc = "Navigate up" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "t" }, desc = "Navigate right" },
    },
  },
}
