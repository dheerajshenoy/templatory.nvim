local function command (name, callback, options)
    local final_opts = vim.tbl_deep_extend('force', options or {}, { bang = true })
    vim.api.nvim_create_user_command(name, callback, final_opts)
end

local options = { "inject", "visit_file", "visit_dir", "new" }

command("Templatory",
    function (opts)
        local fopts = opts.fargs[1]
        if fopts == options[1] then
            require("templatory").inject()

        elseif fopts == options[2] then
            require("templatory").visit_file()

        elseif fopts == options[3] then
            require("templatory").visit_dir()

        elseif fopts == options[4] then
            require("templatory").new()

        -- No options
        elseif fopts == nil then
            require("templatory").info()
        end
    end,
    {
        nargs = "?",
        complete = function (ArgLead, CmdLine, CursorPos)
            return options
        end,
    })


