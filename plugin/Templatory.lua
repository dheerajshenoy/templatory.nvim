local function command (name, callback, options)
  local final_opts = vim.tbl_deep_extend('force', options or {}, { bang = true })
  vim.api.nvim_create_user_command(name, callback, final_opts)
end

local templatory = require("Templatory")

command("TemplatoryNew", function () templatory.create_template() end)
command("TemplatoryVisitFile", function () templatory.visit_file() end)
command("TemplatoryVisitDir", function () templatory.visit_dir() end)
