local M = {}
local utils = require("templatory.utils")
local PLUGIN_NAME = "templatory"
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
        M.__template_insert_helper(vim.fn.readfile(M.skdir .. files[1]))
        return true
    else if nfiles > 1 then
            vim.schedule(function ()
                vim.ui.select(files, { prompt = "Select the template file: ", kind = "number" },
                    function (choice)
                        if choice == nil then
                            return
                        end
                        local content = vim.fn.readfile(M.skdir .. choice)
                        M.__handle_content(content, ext)
                    end)
            end)
            return true
        else
            vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR)
            return false
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

    vim.notify(string.format("%s: Template added", PLUGIN_NAME), logl.INFO)
    return true
end

-- Function that inserts template into the buffer
M.__template_insert = function()

    local ext = vim.fn.expand("%:e")

    if utils.is_skdir() or ext == nil then
        return
    end

    local status = M.__read_file(ext)

    if status == nil then
        vim.notify(string.format("%s: Unable to read skeleton file", PLUGIN_NAME), logl.ERROR)
    end
end

-- Setup function
M.setup = function(opts)

    if opts.skdir then
        M.skdir = opts.skdir
    else
        M.skdir = vim.fn.stdpath("config") .. "/templates/"
    end

    utils.set_skdir(utils.replace_tilde_with_home(M.skdir))

    M.goto_cursor_line = opts.goto_cursor_line or true
    M.cursor_pattern = opts.cursor_pattern or "$C"
    M.prompt = opts.prompt or false
    M.echo_no_file = opts.echo_no_file or false
    M.prompt_for_no_file = opts.prompt_for_no_file or false
    M.auto_insert_template = opts.auto_insert_template or true
    M.prompt_no_skfiles = opts.prompt_no_skfiles or true


    -- Check for skeleton directory
    if M.skdir == nil then
        error(string.format("%s: Please create a skeleton directory and pass to the setup function", PLUGIN_NAME))
    else
        -- if skeleton directory exists
        if vim.fn.isdirectory(M.skdir) == 1 then
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
                if vim.fn.mkdir(M.skdir) then
                    vim.notify(string.format("%s: Skeleton directory created at " .. M.skdir, PLUGIN_NAME), logl.INFO)
                else
                    vim.notify(string.format("%s: Could not create skeleton directory at " .. M.skdir, PLUGIN_NAME), logl.ERROR)
                end
            end
            return
        end
    end
end

M.create_template = function ()
end

M.visit_file = function ()
    local ext = vim.fn.expand("%:e")
    if ext ~= nil then
        local files = utils.get_skfiles_with_ext(ext)
        if #files == 1 then
            vim.cmd("edit " .. M.skdir .. files[1])
        else if #files > 1 then
                vim.ui.select(files, { prompt = "Select the skeleton file" }, function (choice)
                    vim.cmd("edit " .. M.skdir .. choice)
                end)
            else
                vim.notify(string.format("%s: No skeleton file found", PLUGIN_NAME), logl.ERROR)
                return
            end
        end
    else
        if M.prompt_for_no_file then
            utils.prompt_for_no_file(ext)
            return
        end
        vim.notify(string.format("%s: No skeleton file found for this file", PLUGIN_NAME), logl.ERROR)
        return
    end
    vim.notify(string.format("%s: Skeleton file opened for %s file", PLUGIN_NAME, ext), logl.INFO)
end

M.visit_dir = function ()
    vim.cmd("edit " .. M.skdir)
end

return M
