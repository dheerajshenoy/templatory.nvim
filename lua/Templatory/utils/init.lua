local M = {}

M.is_directory = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end


M.is_file = function (path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "file"
end


M.replace_tilde_with_home = function (path)
    -- Check if the path starts with ~
    if string.sub(path, 1, 1) == '~' then
        -- Get the user's home directory
        local home = vim.fn.expand('~')
        -- Replace ~ with the home directory
        path = home .. string.sub(path, 2)
    end
    return path
end

return M
