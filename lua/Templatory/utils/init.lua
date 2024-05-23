local M = {}

M.is_directory = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

return M
