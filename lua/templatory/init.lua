local M = {}

local utils = require("templatory.utils")


local PLUGIN_NAME = "templatory"
local SKFILENAME = "sk"

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

M.__read_file = function (filepath)
    if utils.is_file(filepath) then
        return vim.fn.readfile(filepath)
    else
        return nil
    end
end

-- Function that inserts template into the buffer
M.__template_insert = function()

    local ext = vim.fn.expand("%:e")

    if vim.fn.expand("%:t") == string.format("%s.%s", SKFILENAME, ext) or ext == nil then
        return
    end

    local content = M.__read_file(M.skeleton_dir .. string.format("%s.%s", SKFILENAME, ext))
    if content == nil then
        if M.echo_no_file then
            if M.prompt_for_no_file then
                utils.prompt_for_no_file(M.skeleton_dir, SKFILENAME, ext)
            end
            return
        else
            print("No skeleton file found")
            return
        end
        return
    end

    if M.prompt then
        local input = vim.fn.input("Do you want to insert the template ? (y/n): ")
        if input:lower() == 'y' then
            M.__template_insert_helper(content)
        end
    else
        M.__template_insert_helper(content)
        print("Template added")
    end
end

-- Setup function
M.setup = function(opts)

    if opts ~= nil then

        M.skeleton_dir = utils.replace_tilde_with_home(opts.skeleton_dir)
        M.goto_cursor_line = opts.goto_cursor_line or true
        M.cursor_pattern = opts.cursor_pattern or "$C"
        M.prompt = opts.prompt or false
        M.echo_no_file = opts.echo_no_file or false
        M.prompt_for_no_file = opts.prompt_for_no_file or false
        M.auto_insert_template = opts.auto_insert_template or true

        -- Check for skeleton directory
        if M.skeleton_dir == nil then
            error(string.format("%s: Please create a skeleton directory and pass to the setup function", PLUGIN_NAME))
        else
            -- if skeleton directory exists
            if utils.is_directory(M.skeleton_dir) then
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
    local fext = vim.fn.expand("%:e")
    if fext ~= nil then
        if utils.has_skfile(M.skeleton_dir, fext) then
            vim.cmd("edit " .. M.skeleton_dir .. string.format("sk.%s", fext))
            print(string.format("Skeleton file opened for %s file", fext))
        else
            if M.prompt_for_no_file then
                utils.prompt_for_no_file(M.skeleton_dir, SKFILENAME, fext)
                return
            end
            print("No skeleton file found for this file")
        end
    end
end

M.visit_dir = function ()

end

return M
