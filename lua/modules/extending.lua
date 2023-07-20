local extending = {
	guicursor = "a:hor100",
	keymaps = {
		toggle = "-",
		["x"] = "<S-v>",
		["X"] = "<C-v>",
	},
}
extending.active = false

function extending:toggle()
	extending.active = not extending.active
	if extending.active then
		extending._old_mode = vim.fn.mode()
		print(extending._old_mode)
		extending._old_cursor = vim.o.guicursor
		-- Enter visual mode
		if extending._old_mode ~= "v" and extending._old_mode ~= "V" and extending._old_mode ~= "" then
			-- we need to press <esc> to enter visual mode, so let's do it only if we
			-- are not in visual mode, otherwise we lose the selection
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>v", true, false, true), "n", false)
		end
		-- Change cursor
		vim.opt.guicursor = extending.guicursor
	else
		-- Enter the old mode
		print(extending._old_mode)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
		if extending._old_mode ~= "n" then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(extending._old_mode, true, false, true), "n", false)
		end
		-- reset cursor
		vim.o.guicursor = extending._old_cursor
	end
end

function extending:feedkeys(keys)
	if extending.keymaps[keys] ~= nil then
		keys = extending.keymaps[keys]
	end
	if type(keys) == "string" then
		if keys == extending.keymaps.toggle then
			return extending:toggle()
		end
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
	elseif type(keys) == "function" then
		keys()
	end
end

return extending
