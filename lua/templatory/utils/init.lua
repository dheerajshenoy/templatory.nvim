local M = {}

M.PLUGIN_NAME = "templatory"

-- Set the skeleton directory for ease of access in this file
M.set_templates_dir = function (templates_dir)
    M.templates_dir = templates_dir
end

-- Check if `path` points to a valid file that exists
M.is_file = function (path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "file"
end

M.get_all_dirskfiles = function ()

    local handle, err = vim.loop.fs_scandir(M.templates_dir)
    if not handle then
        vim.notify(string.format("%s: Error opening skeleton directory: " .. err, err), vim.log.levels.ERROR)
        return {}
    end

    local result = {}

    while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then break end

        if typ == 'file' and name:match("%.%w+$") == nil then
            table.insert(result, name)
        end
    end
    return result

end

-- Get all the skeleton files from the skeleton directory
M.get_all_skfiles = function ()
    local handle, err = vim.loop.fs_scandir(M.templates_dir)
    if not handle then
        vim.notify(string.format("%s: Error opening skeleton directory: " .. err, err), vim.log.levels.ERROR)
        return {}
    end

    local result = {}

    while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if typ == "file" then
            table.insert(result, name)
        end
    end
    return result
end

M.check_skfiles = function ()
end

M.replace_tilde_with_home = function (path)

    if path == nil then
        return
    end

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
    if M.is_file(M.templates_dir .. string.format("sk.%s", fext)) then
        return true
    end
    return false
end

M.prompt_for_no_file = function (ext)
    local input = vim.fn.input("No skeleton file found. Do you want to create one ? (y/n): ")
    if input:lower() == 'y' then
        local ft = vim.bo.filetype
        local bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_set_current_buf(bufnr)
        vim.bo.filetype = ft
        vim.notify("New template file opened. Save it once editing is finished with the extension of the required language", vim.log.levels.INFO)
        if ft == nil then
            vim.notify("Could not determine the filetype. Please set the filetype if you wish to", vim.log.levels.WARN)
        end

    else
        return
    end
end

M.is_templates_dir = function ()
    if vim.fn.expand("%:h") == M.templates_dir then
        return true
    end
    return false
end

M.get_skfiles_with_ext = function(ext)
    local handle, err = vim.loop.fs_scandir(M.templates_dir)
    if not handle then
        vim.notify(string.format("%s: Error opening skeleton directory: " .. err, M.PLUGIN_NAME), vim.log.levels.ERROR)
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

-- Check if the given directory is part of the skeleton directory
M.is_skdir = function(dir)

    local handle, err = vim.loop.fs_scandir(M.templates_dir)
    if not handle then
        vim.notify(string.format("%s: Error opening skeleton directory: " .. err, M.PLUGIN_NAME), vim.log.levels.ERROR)
        return {}
    end

    while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if type == 'dir' and name == dir then
            return true
        end
    end

    return false
end

-- Function that returns % separated path to a directory
M.gen_skdir_path = function ()
    local path = vim.fn.getcwd()
    return path.gsub(path, "/", "|")
end

return M
