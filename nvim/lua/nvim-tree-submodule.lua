-- Submodule decorator for nvim-tree
-- Shows icon next to submodule directories

local M = {}

-- Cache submodule paths (absolute paths)
local submodule_cache = {}

-- Find repo root that contains .gitmodules
local function find_repo_root(path)
  local dir = path
  while dir and dir ~= "/" do
    if vim.fn.filereadable(dir .. "/.gitmodules") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

-- Parse .gitmodules to get submodule absolute paths
local function get_submodules(repo_root)
  if submodule_cache[repo_root] then
    return submodule_cache[repo_root]
  end

  local paths = {}
  local gitmodules = repo_root .. "/.gitmodules"
  local file = io.open(gitmodules, "r")
  if file then
    for line in file:lines() do
      local path = line:match("^%s*path%s*=%s*(.+)")
      if path then
        path = path:gsub("%s+$", "")
        paths[repo_root .. "/" .. path] = true
      end
    end
    file:close()
  end

  submodule_cache[repo_root] = paths
  return paths
end

--- Setup submodule decorator
--- @param icon string Icon to show (default "@")
--- @param color string Hex color (default "#2aa198")
--- @return table decorator class for nvim-tree
function M.setup(icon, color)
  icon = icon or "@"
  color = color or "#2aa198"

  -- Setup highlights
  local function set_hl()
    vim.api.nvim_set_hl(0, "NvimTreeSubmoduleIcon", { fg = color, bold = true })
    vim.api.nvim_set_hl(0, "NvimTreeSubmoduleName", { fg = color })
  end
  set_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

  -- Create decorator class
  local UserDecorator = require("nvim-tree.api").decorator.UserDecorator
  local SubmoduleDecorator = UserDecorator:extend()

  function SubmoduleDecorator:new()
    self.enabled = true
    self.highlight_range = "name"
    self.icon_placement = "before"
    self.icon = { str = icon, hl = { "NvimTreeSubmoduleIcon" } }
  end

  function SubmoduleDecorator:icons(node)
    if node.type ~= "directory" then return nil end
    local repo_root = find_repo_root(node.absolute_path)
    if not repo_root then return nil end
    if get_submodules(repo_root)[node.absolute_path] then
      return { self.icon }
    end
    return nil
  end

  function SubmoduleDecorator:highlight_group(node)
    if node.type ~= "directory" then return nil end
    local repo_root = find_repo_root(node.absolute_path)
    if not repo_root then return nil end
    if get_submodules(repo_root)[node.absolute_path] then
      return "NvimTreeSubmoduleName"
    end
    return nil
  end

  return SubmoduleDecorator
end

function M.clear_cache()
  submodule_cache = {}
end

return M
