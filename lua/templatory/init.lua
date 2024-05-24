local M = {}
local utils = require("templatory.utils")
local PLUGIN_NAME = "templatory"
local augroup = vim.api.nvim_create_augroup(PLUGIN_NAME, { clear = true })


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
            print("No skeleton file found")
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

    print("Template added")
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
        print("Unable to read skeleton file")
    end
end

-- Setup function
M.setup = function(opts)

    if opts ~= nil then

        M.skdir = utils.replace_tilde_with_home(opts.skdir)
        utils.set_skdir(M.skdir)
        M.goto_cursor_line = opts.goto_cursor_line or true
        M.cursor_pattern = opts.cursor_pattern or "$C"
        M.prompt = opts.prompt or false
        M.echo_no_file = opts.echo_no_file or false
        M.prompt_for_no_file = opts.prompt_for_no_file or false
        M.auto_insert_template = opts.auto_insert_template or true

        -- Check for skeleton directory
        if M.skdir == nil then
            error(string.format("%s: Please create a skeleton directory and pass to the setup function", PLUGIN_NAME))
        else
            -- if skeleton directory exists
            if utils.is_directory(M.skdir) then
                if M.auto_insert_template then
                    vim.api.nvim_create_autocmd("BufNewFile", {
                        group = augroup,
                        desc = "Insert template into newly created file if the skeleton file for it exists",
                        once = true,
                        callback = M.__template_insert
                    })
                end
            else
                -- Else print error
                error(string.format("%s: Skeleton directory doesn't exist", PLUGIN_NAME))
            end
        end
    else
        -- if opts table not passed print error
        error(string.format("%s: Pass an opts table", PLUGIN_NAME))
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
                print("No skeleton file found")
                return
            end
        end
    else
        if M.prompt_for_no_file then
            utils.prompt_for_no_file(ext)
            return
        end
        print("No skeleton file found for this file")
        return
    end
    print(string.format("Skeleton file opened for %s file", ext))
end

M.visit_dir = function ()
    vim.cmd("edit " .. M.skdir)
end

return M
