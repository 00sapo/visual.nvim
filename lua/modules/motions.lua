local M = {}

local unpack = unpack or table.unpack

function M.is_word_boundary(line, col, direction)
  local count = 0

  if direction == 'r' then
    count = 1
  elseif direction == 'l' then
    count = -1
  else
    error('direction must be "r" or "l"')
  end

  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

  -- If the current word has only one character, move to the next word.
  local this_char = line_content:sub(col, col)
  local next_char = line_content:sub(col + count, col + count)
  local class1, class2
  if string.match(this_char, "%s") or string.match(this_char, "%p") then
    class1 = 1
  else
    class1 = 2
  end
  if string.match(next_char, "%s") or string.match(next_char, "%p") then
    class2 = 1
  else
    class2 = 2
  end

  if (class1 == 1 and class2) == 2 or (class1 == 2 and class2 == 1) then
    return true
  else
    return false
  end
end

--- Move the cursor till the vim.v.count1-th end of word.
-- If the current word has only one character, moves to the next word before applying the motion.
-- This function is useful for quickly navigating through text in a vim buffer.
function M.till_end_word()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  print(vim.inspect({line, col}))

  if M.is_word_boundary(line, col, 'r') then
    vim.api.nvim_feedkeys('w', 'v', true)
  end
  line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if M.is_word_boundary(line, col, 'r') and vim.v.count1 == 1 then
    return
  end

  -- Move the cursor till the count-th end of word.
  for _ = 1, vim.v.count1 do
    vim.api.nvim_feedkeys('e', 'v', true)
  end
end

return M
