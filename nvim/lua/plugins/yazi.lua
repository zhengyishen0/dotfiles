return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  opts = {
    open_for_directories = false,
    floating_window_scaling_factor = 0.75,
    yazi_floating_window_border = "rounded",
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      change_working_directory = false,
      copy_relative_path_to_selected_files = false,
    },
    hooks = {
      yazi_closed_successfully = function(chosen_file, config, state)
        vim.schedule(function()
          local dir

          if chosen_file then
            -- Enter was pressed on something
            local path = type(chosen_file) == "string" and chosen_file or tostring(chosen_file)
            if vim.fn.isdirectory(path) == 1 then
              -- Chose a directory: switch cwd
              dir = path
            end
            -- Chose a file: yazi.nvim opens it, nothing extra needed
          elseif state and state.last_directory then
            -- q was pressed: switch cwd to last viewed directory
            dir = state.last_directory.filename or tostring(state.last_directory)
          end

          if dir then
            vim.cmd.cd(dir)
            local ok, nvtree_api = pcall(require, "nvim-tree.api")
            if ok then
              nvtree_api.tree.change_root(dir)
            end
          end
        end)
      end,
    },
  },
}
