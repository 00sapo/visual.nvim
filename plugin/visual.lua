-- if vim.fn.has("nvim-0.7.0") == 0 then
--   vim.api.nvim_err_writeln("visual.nvim requires at least nvim-0.7.0.1")
--   return
-- end

-- make sure this file is loaded only once
if vim.g.loaded_visual == 1 then
	return
end
vim.g.loaded_visual = 1

vim.api.nvim_create_user_command("VisualEnable", require("visual").setup, {})
vim.api.nvim_create_user_command("VisualDisable", require("visual").disable, {})
