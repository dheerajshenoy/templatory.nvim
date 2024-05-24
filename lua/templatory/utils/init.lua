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

-- Checks if the current buffer has a skfile associated with it
M.has_skfile = function (skdir, fext)
    if M.is_file(skdir .. string.format("sk.%s", fext)) then
        return true
    else
        return false
    end
end

M.prompt_for_no_file = function (skdir, skfile, ext)
    local input = vim.fn.input("No skeleton file found. Do you want to create one ? (y/n): ")
    if input:lower() == 'y' then
        vim.api.nvim_command("edit " .. skdir .. string.format("%s.%s", skfile, ext))
        vim.api.nvim_set_option_value("filetype", vim.bo.filetype, {})
    end
end

return M
