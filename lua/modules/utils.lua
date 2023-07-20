local utils = {}

function utils.enter(mode)
	if mode == "v" then
		vim.api.nvim_feedkeys("v", "n", false)
	elseif mode == "n" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
	end
end

function utils.mode_is_visual()
  local mode = vim.fn.mode()
  return mode == "v" or mode == "V" or mode == "" 
end

return utils
