history = {}
history.selection_history = {}
history.cur_history_idx = 0

function history.push_history(selection) 
  -- if cur_history_idx is > 1, delete everything before
  if history.cur_history_idx > 1 then
    table.remove(history.selection_history, 1, history.cur_history_idx)
  end

  table.insert(history.selection_history, selection)
  if #history.selection_history > history.history_size then
    -- remove the oldest entry
    table.remove(history.selection_history, #history.selection_history)
  end
  history.cur_history_idx = 1
end

function history.get_history_prev()
  -- if there is no previous item, return nil
  if history.cur_history_idx + 1 > #history.selection_history then
    return nil
  end
  -- increment counter
  history.cur_history_idx = history.cur_history_idx + 1
  return history.selection_history[history.cur_history_idx]
end

function history.get_history_next()
  -- if there is no previous item, return nil
  if history.cur_history_idx - 1 < 1 then
    return nil
  end
  -- same as get_history_prev, but for next
  history.cur_history_idx = history.cur_history_idx - 1
  return history.selection_history[history.cur_history_idx]
end

function history.set_selection_idx(idx)
  if #history.selection_history < idx then
    return nil
  end
  history.set_selection(history.selection_history[idx])
  history.cur_history_idx = idx
end

function history.set_selection(selection)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', false)
  print(vim.inspect(selection))
  vim.fn.cursor(selection[1])
  vim.api.nvim_feedkeys('', 'v', true)
  vim.fn.cursor(selection[2])
end

function history.set_history_next()
  history.set_selection(history.get_history_next())
end

function history.set_history_prev()
  history.set_selection(history.get_history_prev())
end

return history
