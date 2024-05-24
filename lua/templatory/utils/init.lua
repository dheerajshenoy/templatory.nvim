local M = {}

M.set_skdir = function (skdir)
    M.skdir = skdir
end

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
M.has_skfile = function (fext)
    if M.is_file(M.skdir .. string.format("sk.%s", fext)) then
        return true
    end
    return false
end

M.prompt_for_no_file = function (ext)
    local input = vim.fn.input("No skeleton file found. Do you want to create one ? (y/n): ")
    if input:lower() == 'y' then
        -- TODO : detect if there are multiple files. If there are, provide a ui select menu to select the template required.
        -- vim.api.nvim_command("edit " .. M.skdir .. string.format("%s.%s", ext))
        vim.api.nvim_set_option_value("filetype", vim.bo.filetype, {})
    end
end

M.is_skdir = function ()
    if vim.fn.expand("%:h") == M.skdir then
        return true
    end
    return false
end

M.get_skfiles_with_ext = function(ext)
    local handle, err = vim.loop.fs_scandir(M.skdir)
    if not handle then
        print("Error opening skeleton directory: " .. err)
        return {}
    end

    local result = {}

    while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if typ == 'file' and name:sub(-#ext) == ext then
            table.insert(result, name)
        end
    end
    return result

end

return M
