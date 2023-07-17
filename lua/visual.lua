local visual = {}

local function with_defaults(options)
   return {
     mappings = {
       -- a list of command names, mapped to a lhs of mapping for visual and
       -- normal mode
       WORD_next = "w", -- select next WORD (punctuation included)
       word_next = "e", -- select next word (no punctuation included)
       WORD_prev = "z", -- select previous WORD
       word_prev = "b", -- select previous word
       from_cursor_to_end_word = "E", -- select from the cursor position to the end of the word (as traditional e)
       from_cursor_to_start_word = "B", -- select from the cursor position to the beginning of the word (as traditional b)
       from_cursor_to_start_word_next = "W", -- select from the cursor position to the beginning of the next word (as traditional w)
       extend_word_end = "-e", -- extend until end of word
       extend_word_prev = "-b", -- extend current selection until previous begin of word
       extend_word_next = "-w", -- extend current selection until next word
       extend_find_next = "-f", -- extend current selection to next char
       extend_find_prev = "-F", -- extend current selection to previous char
       extend_till_next = "-t", -- extend current selection till next char
       extend_till_prev = "-T", -- extend current selection till previous char
       find_next = "f", -- select to next char
       find_prev = "F", -- select to previous char
       till_next = "t", -- select till next char
       till_prev = "T", -- select till previous char
       append_at_cursor = "a", -- append at cursor position
       insert_at_cursor = "i", -- insert at cursor position
       select_inside = "si", -- select inside
       select_around = "sa", -- select around
     },
     only_normal_mappings = {
       -- mappings applied to normal mode only:
       -- {lhs, {rhs1, rhs2, rhs3}}
       line_select = {"y", {"<S-v>"}},
       block_select = {"c", {"<C-v>"}},
     },
     only_visual_mappings = {
       -- mappings applied to visual mode only:
       -- {lhs, {rhs1, rhs2, rhs3}}
       to_normal_mode = {"x", {"<esc>"}},
       restart_selection = {"--", {"<esc>v"}},
       delete_single_char = {"D", {"d"}}, -- delete char under cursor
       replace_single_char = {"R", {"r"}}, -- replace char under cursor
       -- delete_single_char = {"D", {"d", function() require('visual').set_selection_idx(2) end}}, -- delete char under cursor
       -- replace_single_char = {"R", {"r", function() require('visual').set_selection_idx(2) end}}, -- replace char under cursor
     },
     commands = {
       -- what each command name does:
       WORD_next = {
         -- first, the editor is switched to normal mode
         {"W"}, -- if in visual mode, these keys are executed
         -- then, the editor is switched to normal mode
         {"iW"} -- these keys are executed
         -- in place of keys, you can use one or more functions (no argument
         -- allowed), or both of them
       },
       
       word_next = {{"w"}, {"iw"}},
       WORD_prev = {{"B"}, {"iWo"}},
       word_prev = {{"b"}, {"iwo"}},
       from_cursor_to_end_word = {{}, {"e"}},
       from_cursor_to_start_word = {{}, {"b"}},
       from_cursor_to_start_word_next = {{}, {"w"}},
       extend_word_end = {{}, {"gve"}},
       extend_word_prev = {{}, {"gvb"}},
       extend_word_next = {{}, {"gvw"}},
       extend_word_next = {{}, {"gvw"}},
       extend_find_next = {{}, {"gvf"}},
       extend_find_prev = {{}, {"gvF"}},
       extend_till_next = {{}, {"gvt"}},
       extend_till_prev = {{}, {"gvT"}},
       find_next = {{}, {"f"}},
       find_prev = {{}, {"F"}},
       till_next = {{}, {"t"}},
       till_prev = {{}, {"T"}},
       append_at_cursor = {{}, {"<esc>a"}},
       insert_at_cursor = {{}, {"<esc>i"}},
       select_inside = {{}, {"i"}},
       select_around = {{}, {"a"}},
       prev_selection = {{}, {function() require('visual').set_selection(visual.get_history_prev()) end}},
       next_selection = {{}, {function() require('visual').set_selection(visual.get_history_next()) end}},
     },
     -- commands that can be unmapped (for learning new keymaps)
     unmaps = {"W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc"},
     history_size = 50 -- ho many selections we should remember
   }
end

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
   -- avoid setting global values outside of this function. Global state
   -- mutations are hard to debug and test, so having them in a single
   -- function/module makes it easier to reason about all possible changes
   visual.options = with_defaults(options)
end

local function apply_key(key)
  if type(key) == 'function' then
    key()
  elseif type(key) == 'string' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
  end
end

visual.selection_history = {}
visual.cur_history_idx = 0

function visual.push_history(selection) 
  -- if cur_history_idx is > 1, delete everything before
  if visual.cur_history_idx > 1 then
    table.remove(visual.selection_history, 1, visual.cur_history_idx)
  end

  table.insert(visual.selection_history, selection)
  if #visual.selection_history > visual.options.history_size then
    -- remove the oldest entry
    table.remove(visual.selection_history, #visual.selection_history)
  end
  visual.cur_history_idx = 1
end

function visual.get_history_prev()
  -- if there is no previous item, return nil
  if visual.cur_history_idx + 1 > #visual.selection_history then
    return nil
  end
  -- increment counter
  visual.cur_history_idx = visual.cur_history_idx + 1
  return visual.selection_history[visual.cur_history_idx]
end

function visual.get_history_next()
  -- if there is no previous item, return nil
  if visual.cur_history_idx - 1 < 1 then
    return nil
  end
  -- same as get_history_prev, but for next
  visual.cur_history_idx = visual.cur_history_idx - 1
  return visual.selection_history[visual.cur_history_idx]
end

function visual.set_selection_idx(idx)
  if #visual.selection_history < idx then
    return nil
  end
  visual.set_selection(visual.selection_history[idx])
  visual.cur_history_idx = idx
end

function visual.set_selection(selection)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', false)
  vim.fn.setpos('.', selection[1])
  vim.api.nvim_feedkeys('', 'v', true)
  vim.fn.setpos('.', selection[2])
end

function visual.get_mapping_func(keys, mode)
  local function f()
    if mode == 'v' then
      -- Save current selection to history
      local selection = {
        vim.fn.getpos('v'), vim.fn.getpos('.')
      }
      visual.push_history(selection)

      -- Enter normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', false)

      -- pre-visual keys
      for _, key in pairs(keys[1]) do
        apply_key(key)
      end
    end
    -- Enter visual mode
    vim.api.nvim_feedkeys('v', 'n', false)

    -- visual keys
    for _, key in pairs(keys[2]) do
      apply_key(key)
    end
  end
  return f
end

visual.options = with_defaults()
return visual
