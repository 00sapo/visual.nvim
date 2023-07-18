history = {}
history.selection_history = {}
history.cur_history_idx = 0

function history.push_history(selection) 
  -- if cur_history_idx is > 1, delete everything before
  if history.cur_history_idx > 1 then
    table.remove(history.selection_history, 1, visual.cur_history_idx)
  end

  table.insert(history.selection_history, selection)
  if #history.selection_history > visual.options.history_size then
    -- remove the oldest entry
    table.remove(history.selection_history, #visual.selection_history)
  end
  history.cur_history_idx = 1
end

function history.get_history_prev()
  -- if there is no previous item, return nil
  if history.cur_history_idx + 1 > #visual.selection_history then
    return nil
  end
  -- increment counter
  history.cur_history_idx = visual.cur_history_idx + 1
  return history.selection_history[visual.cur_history_idx]
end

function history.get_history_next()
  -- if there is no previous item, return nil
  if history.cur_history_idx - 1 < 1 then
    return nil
  end
  -- same as get_history_prev, but for next
  history.cur_history_idx = visual.cur_history_idx - 1
  return history.selection_history[visual.cur_history_idx]
end

function history.set_selection_idx(idx)
  if #history.selection_history < idx then
    return nil
  end
  history.set_selection(visual.selection_history[idx])
  history.cur_history_idx = idx
end

function history.set_selection(selection)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', false)
  vim.fn.setpos('.', selection[1])
  vim.api.nvim_feedkeys('', 'v', true)
  vim.fn.setpos('.', selection[2])
end

return history
