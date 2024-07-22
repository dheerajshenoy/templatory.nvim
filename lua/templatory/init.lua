local M = {}
local utils = require("templatory.utils")
local PLUGIN_NAME = utils.PLUGIN_NAME
local logl = vim.log.levels
local augroup = vim.api.nvim_create_augroup(PLUGIN_NAME, { clear = true })

local funcs = {}

local default_config = {
    templates_dir = vim.fn.stdpath("config") .. "/templates/",
    goto_cursor_line = true,
    cursor_pattern = "$C",
    prompt = false,
    echo_no_file = false,
    prompt_for_no_file = false,
    auto_insert_template = true,
    prompt_no_skfiles = true,
    dir_filetypes = { "netrw", "oil", "NvimTree" },
}

local local_config = vim.tbl_deep_extend('keep', default_config, {})

-- Setup function
M.setup = function(opts)

    local_config = vim.tbl_deep_extend('keep', opts or {}, default_config)

    -- if local_config.templates_dir == nil then
    --     M.templates_dir = vim.fn.stdpath("config") .. "/templates/"
    -- end

    -- Replace tilde with /home/username
    if local_config.templates_dir then
        local_config.templates_dir = utils.replace_tilde_with_home(local_config.templates_dir)
    end

    utils.set_templates_dir(local_config.templates_dir)

    -- Check for skeleton directory
    if local_config.templates_dir == nil or local_config.templates_dir == "" then
        error(string.format("%s: Please specify a templates directory to the setup function option: `templates_dir`", PLUGIN_NAME))
    else
        -- if skeleton directory exists
        if vim.fn.isdirectory(local_config.templates_dir) == 1 then

            if local_config.prompt_no_skfiles and #utils.get_all_skfiles() == 0 then
                vim.schedule(function() vim.notify(string.format("%s: No skeleton files found!", PLUGIN_NAME), logl.WARN) end)
            end

            if local_config.auto_insert_template then
                vim.api.nvim_create_autocmd( "BufNewFile", {
                    group = augroup,
                    desc = "Insert template into newly created file if the skeleton file for it exists",
                    once = true,
                    callback = funcs.__template_insert
                })

                -- -- Funky hack for when opening files through `nvim filename`
                -- -- The BufNewFile is not being triggered, so had to come up with this hacky solution
                -- -- where we check if the file exists or not. If it doesn't insert the template code
                --
                -- local bufnr = vim.api.nvim_get_current_buf()
                -- local filename = vim.api.nvim_buf_get_name(bufnr)
                --
                -- if vim.fn.filereadable(filename) == 0 then
                --     funcs.__template_insert()
                -- end

            else
                vim.api.nvim_del_augroup_by_name(PLUGIN_NAME)
            end
        else
            local res = vim.fn.input(string.format("%s: Skeleton directory doesn't exist. Do you want to create it ? (y/n): ", PLUGIN_NAME))
            if res:lower() == 'y' then
                if vim.fn.mkdir(local_config.templates_dir) then
                    vim.schedule(function() vim.notify(string.format("%s: Skeleton directory created at " .. local_config.templates_dir, PLUGIN_NAME), logl.INFO) end)
                else
                    vim.schedule(function() vim.notify(string.format("%s: Could not create skeleton directory at " .. local_config.templates_dir, PLUGIN_NAME), logl.ERROR) end)
                end
            end
            return
        end
    end
end

local __template_insert_helper = function (content)
    local bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

    if local_config.goto_cursor_line then
        local ln = vim.fn.search(local_config.cursor_pattern, "nw")
        if ln ~= 0 then
            vim.api.nvim_win_set_cursor(0, { ln, 0 })
            vim.api.nvim_buf_set_lines(bufnr, ln - 1, ln, false, { "" })
            vim.api.nvim_win_set_cursor(0, { ln, 0 })
        end
    end
end

funcs.__handle_content = function (content, ext)
    if local_config.prompt then
        local input = vim.fn.input("Do you want to insert the template ? (y/n): ")
        if input:lower() == 'y' then
            __template_insert_helper(content)
        end
    else
        __template_insert_helper(content)
    end

    vim.schedule(function() vim.notify(string.format("%s: Template added", PLUGIN_NAME), logl.INFO) end)
    return true
end

funcs.__read_file = function (ext)
    local files = utils.get_skfiles_with_ext(ext)
    local nfiles = #files

    if nfiles == 1 then
        __template_insert_helper(vim.fn.readfile(local_config.templates_dir .. "/" .. files[1]))
        return true
    else if nfiles > 1 then
            vim.schedule(function ()
                vim.ui.select(files, { prompt = "Select the template file: ", kind = "number" },
                    function (choice)
                        if choice == nil then
                            return
                        end
                        local content = vim.fn.readfile(local_config.templates_dir .. choice)
                        funcs.__handle_content(content, ext)
                    end)
            end)
            return true
        else
            vim.schedule(function () vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR) end)
            return nil
        end
    end
end

-- Check if the current file is in a directory that is a directory skeleton
funcs.__is_a_dirsk = function ()

    local files = utils.get_all_dirskfiles()

    for _, v in pairs(files) do
        local dd = string.gsub(v, "|", "/")
        if vim.fn.getcwd() == dd then
            return { dd, v }
        end
    end

    return false
end


-- Function that inserts template into the buffer
funcs.__template_insert = function()

    -- Do not insert anything to newly created template files. (It would be kind of a loop behaviour)
    if utils.is_templates_dir() then
        return
    end

    local ext = vim.fn.expand("%:e")

    local res = funcs.__is_a_dirsk()

    if res ~= false then
        if res[1] ~= nil then

            local bufnr = vim.api.nvim_get_current_buf()
            local content = vim.fn.readfile(local_config.templates_dir .. "/" .. res[2])
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

            if local_config.goto_cursor_line then
                local ln = vim.fn.search(local_config.cursor_pattern, "nw")
                if ln ~= 0 then
                    vim.api.nvim_win_set_cursor(0, { ln, 0 })
                    vim.api.nvim_buf_set_lines(bufnr, ln - 1, ln, false, { "" })
                    vim.api.nvim_win_set_cursor(0, { ln, 0 })
                end
            end
        end
        return
    end

    local status = funcs.__read_file(ext)

    if status == nil then
        vim.schedule(function () vim.notify(string.format("%s: Unable to read skeleton file", PLUGIN_NAME), logl.ERROR) end)
    end
end

-- Function that injects template file content to the current buffer. This can be used if auto insertion of templates is disabled
M.inject = function ()
    funcs.__template_insert()
end


funcs.__is_buf_a_dir = function ()

    local bft = vim.bo.filetype

    if bft == "" then
        return vim.fn.isdirectory(vim.api.nvim_get_current_buf())
    end

    for _, fts in pairs(local_config.dir_filetypes) do
        if bft == fts then
            return true
        end
    end

    return false
end

-- Create a new template
M.new = function ()

    local ft = vim.bo.filetype

    -- If the opened buffer is a directory
    if funcs.__is_buf_a_dir() then
        local bufnr = vim.api.nvim_create_buf(true, false)

        vim.bo[bufnr].filetype = ft
        vim.bo[bufnr].modified = true
        --
        -- -- Switch to it
        local old_dir = vim.fn.getcwd()
        vim.api.nvim_set_current_dir(local_config.templates_dir)
        --
        -- -- Set name
        local name = utils.gen_skdir_path(old_dir)
        --
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_buf_set_name(bufnr, name)
        vim.schedule(function() vim.notify("New template file opened. Save it once editing is finished", vim.log.levels.INFO) end)
        return
    end

    if ft ~= nil then
        local bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_set_current_dir(local_config.templates_dir)
        vim.bo.filetype = ft
        vim.schedule(function() vim.notify("New template file opened. Save it once editing is finished with the extension of the required language", vim.log.levels.INFO) end)
    end
end

-- Visit the current buffer filetype template file if it exists
M.visit_file = function ()
    local ext = vim.fn.expand("%:e")
    if ext ~= nil then
        local files = utils.get_skfiles_with_ext(ext)
        if #files == 1 then
            vim.cmd("edit " .. local_config.templates_dir .. files[1])
        else if #files > 1 then
                vim.ui.select(files, { prompt = "Select the skeleton file" }, function (choice)
                    vim.cmd("edit " .. local_config.templates_dir .. choice)
                end)
            else
                vim.schedule(function() vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR) end)
                return
            end
        end
    else
        -- Check if file is inside a template directory
        if utils.is_skdir(vim.fn.getcwd()) then

        end

        if local_config.prompt_for_no_file then
            utils.prompt_for_no_file(ext)
            return
        end
        vim.schedule(function() vim.notify(string.format("%s: No skeleton file found for this file", PLUGIN_NAME), logl.ERROR) end)
        return
    end
    vim.schedule(function() vim.notify(string.format("%s: Skeleton file opened for %s file", PLUGIN_NAME, ext), logl.INFO) end)
end

-- Visit the templates directory
M.visit_dir = function ()
    vim.cmd("edit " .. local_config.templates_dir)
end

-- Function that displays info about the template files in the template directory
M.info = function ()
    local nfiles = #utils.get_all_skfiles()

    if nfiles > 1 then
        vim.schedule(function() vim.notify(string.format("%s: Found %d template files in the '%s' skeleton directory.", PLUGIN_NAME, nfiles, local_config.templates_dir), logl.INFO) end)
    else
        vim.schedule(function() vim.notify(string.format("%s: Found %d template file in the '%s' skeleton directory.", PLUGIN_NAME, nfiles, local_config.templates_dir), logl.INFO) end)
    end
end

return M
