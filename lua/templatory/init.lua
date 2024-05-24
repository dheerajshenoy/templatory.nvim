local M = {}
local utils = require("templatory.utils")
local PLUGIN_NAME = utils.PLUGIN_NAME
local augroup = vim.api.nvim_create_augroup(PLUGIN_NAME, { clear = true })
local logl = vim.log.levels

M.__template_insert_helper = function (content)
    local bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

    if M.goto_cursor_line then
        local ln = vim.fn.search(M.cursor_pattern, "nw")
        if ln ~= 0 then
            vim.api.nvim_win_set_cursor(0, { ln, 0 })
            vim.api.nvim_buf_set_lines(bufnr, ln - 1, ln, false, { "" })
            vim.api.nvim_win_set_cursor(0, { ln, 0 })
        end
    end
end

M.__read_file = function (ext)
    local files = utils.get_skfiles_with_ext(ext)
    local nfiles = #files

    if nfiles == 1 then
        M.__template_insert_helper(vim.fn.readfile(M.templates_dir .. files[1]))
        return true
    else if nfiles > 1 then
            vim.schedule(function ()
                vim.ui.select(files, { prompt = "Select the template file: ", kind = "number" },
                    function (choice)
                        if choice == nil then
                            return
                        end
                        local content = vim.fn.readfile(M.templates_dir .. choice)
                        M.__handle_content(content, ext)
                    end)
            end)
            return true
        else
            vim.schedule(function () vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR) end)
            return nil
        end
    end
end

M.__handle_content = function (content, ext)

    if M.prompt then
        local input = vim.fn.input("Do you want to insert the template ? (y/n): ")
        if input:lower() == 'y' then
            M.__template_insert_helper(content)
        end
    else
        M.__template_insert_helper(content)
    end

    vim.schedule(function() vim.notify(string.format("%s: Template added", PLUGIN_NAME), logl.INFO) end)
    return true
end

-- Function that inserts template into the buffer
M.__template_insert = function()

    local ext = vim.fn.expand("%:e")

    if utils.is_templates_dir() or ext == nil then
        return
    end

    local status = M.__read_file(ext)

    if status == nil then
        vim.schedule(function () vim.notify(string.format("%s: Unable to read skeleton file", PLUGIN_NAME), logl.ERROR) end)
    end
end

-- Setup function
M.setup = function(opts)

    if opts.templates_dir then
        M.templates_dir = opts.templates_dir
    else
        M.templates_dir = vim.fn.stdpath("config") .. "/templates/"
    end

    M.templates_dir = utils.replace_tilde_with_home(M.templates_dir)

    utils.set_templates_dir(M.templates_dir)

    M.goto_cursor_line = opts.goto_cursor_line or true
    M.cursor_pattern = opts.cursor_pattern or "$C"
    M.prompt = opts.prompt or false
    M.echo_no_file = opts.echo_no_file or false
    M.prompt_for_no_file = opts.prompt_for_no_file or false
    M.auto_insert_template = opts.auto_insert_template or true
    M.prompt_no_skfiles = opts.prompt_no_skfiles or true


    -- Check for skeleton directory
    if M.templates_dir == nil then
        error(string.format("%s: Please create a skeleton directory and pass to the setup function", PLUGIN_NAME))
    else
        -- if skeleton directory exists
        if vim.fn.isdirectory(M.templates_dir) == 1 then
            if M.prompt_no_skfiles and #utils.get_all_skfiles() == 0 then
                vim.schedule(function() vim.notify(string.format("%s: No skeleton files found!", PLUGIN_NAME), logl.WARN) end)
            end
            if M.auto_insert_template then
                vim.api.nvim_create_autocmd("BufNewFile", {
                    group = augroup,
                    desc = "Insert template into newly created file if the skeleton file for it exists",
                    once = true,
                    callback = M.__template_insert
                })
            end
        else
            local res = vim.fn.input(string.format("%s: Skeleton directory doesn't exist. Do you want to create it ? (y/n): ", PLUGIN_NAME))
            if res:lower() == 'y' then
                if vim.fn.mkdir(M.templates_dir) then
                    vim.schedule(function() vim.notify(string.format("%s: Skeleton directory created at " .. M.templates_dir, PLUGIN_NAME), logl.INFO) end)
                else
                    vim.schedule(function() vim.notify(string.format("%s: Could not create skeleton directory at " .. M.templates_dir, PLUGIN_NAME), logl.ERROR) end)
                end
            end
            return
        end
    end
end

-- Create a new template
M.new = function ()
    local ft = vim.bo.filetype
    if ft ~= nil then
        local bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_set_current_dir(M.templates_dir)
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
            vim.cmd("edit " .. M.templates_dir .. files[1])
        else if #files > 1 then
                vim.ui.select(files, { prompt = "Select the skeleton file" }, function (choice)
                    vim.cmd("edit " .. M.templates_dir .. choice)
                end)
            else
                vim.schedule(function() vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR) end)
                return
            end
        end
    else
        if M.prompt_for_no_file then
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
    vim.cmd("edit " .. M.templates_dir)
end

-- Function that injects template file content to the current buffer. This can be used if auto insertion of templates is disabled
M.inject = function ()
    M.__template_insert()
end

-- Function that displays info about the template files in the template directory
M.info = function ()
    local nfiles = #utils.get_all_skfiles()
    
    if nfiles > 1 then
        vim.schedule(function() vim.notify(string.format("%s: Found %d template files in the '%s' skeleton directory.", PLUGIN_NAME, nfiles, M.templates_dir), logl.INFO) end)
    else
        vim.schedule(function() vim.notify(string.format("%s: Found %d template file in the '%s' skeleton directory.", PLUGIN_NAME, nfiles, M.templates_dir), logl.INFO) end)
    end
end

return M
