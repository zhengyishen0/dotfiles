require "nvchad.options"

-- add yours here!

local o = vim.o
o.cmdheight = 0  -- Remove gap at bottom (command line only shows when needed)
o.relativenumber = true  -- Show relative line numbers for easy {n}j/k navigation
o.selectmode = "mouse"   -- Mouse selection uses select mode (typing replaces)
o.equalalways = false    -- Don't auto-resize windows when opening/closing splits
