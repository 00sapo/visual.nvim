local utils = {}

function utils.enter(mode)
	if mode == "v" then
		vim.api.nvim_feedkeys("v", "n", false)
	elseif mode == "n" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
	end
end

function utils.mode_is_visual_arg(mode)
  return mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode:sub(1, 1) == ""
end

function utils.mode_is_visual()
  local mode = vim.fn.mode()
  return utils.mode_is_visual_arg(mode)
end

function utils.prequire(m)
  local ok, err = pcall(require, m)
  if not ok then return nil, err end
  return err
end

function utils.concat_arrays(arrays)
  local result = {}
  for i = 1, #arrays do
    for j = 1, #arrays[i] do
      table.insert(result, arrays[i][j])
    end
  end
  return result
end


return utils
