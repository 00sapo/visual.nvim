local visual = {}

-- history = require'moodules.history'
mappings = require'modules.mappings'

local function with_defaults(options)
   local defaults =  {
     mappings = {
       -- a list of command names, mapped to a lhs of mapping for visual and
       -- normal mode
       WORD_next = "E", -- select next WORD (punctuation included)
       word_next = "e", -- select next word (no punctuation included)
       WORD_prev = "gE", -- select previous WORD
       word_prev = "ge", -- select previous word
       till_next_word = "w", -- select next word including next its space
       till_next_WORD = "W", -- select next WORD including its next space
       till_prev_word = "b", -- select previous word including its previous space
       till_prev_WORD = "B", -- select previous WORD including its previous space
       -- from_cursor_to_end_word = "E", -- select from the cursor position to the end of the word (as traditional e)
       -- from_cursor_to_start_word = "B", -- select from the cursor position to the beginning of the word (as traditional b)
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
       line_select = {"x", {"<S-v>"}},
       block_select = {"<S-x>", {"<C-v>"}},
       delete_char = {"y", {"x"}}
     },
     only_visual_mappings = {
       -- mappings applied to visual mode only:
       -- {lhs, {rhs1, rhs2, rhs3}}
       line_select = {"x", {"<S-v>"}},
       block_select = {"X", {"<C-v>"}},
       restart_selection = {"'", {"<esc>v"}},
       delete_single_char = {"D", {"<esc>x"}}, -- delete char under cursor
       replace_single_char = {"R", {"<esc>r"}}, -- replace char under cursor
      -- if they are strings, use the value from "commands" table
       extend_word_end = "-e", -- extend until end of word
       extend_word_prev = "-b", -- extend current selection until previous begin of word
       extend_word_next = "-w", -- extend current selection until next word
       extend_find_next = "-f", -- extend current selection to next char
       extend_find_prev = "-F", -- extend current selection to previous char
       extend_till_next = "-t", -- extend current selection till next char
       extend_till_prev = "-T", -- extend current selection till previous char
       -- delete_surround_chars = {"<C-s>", {"dgvodgv"}} -- delete chars at the
       -- extremes of the selection
       -- delete_single_char = {"D", {"d", function() require('visual').set_selection_idx(2) end}}, -- delete char under cursor
       -- replace_single_char = {"R", {"r", function() require('visual').set_selection_idx(2) end}}, -- replace char under cursor
     },
     commands = {
       -- what each command name does:
       WORD_next = {
         -- first, the editor is switched to normal mode
         {"W"}, -- if the command is launched in visual mode, these keys are executed
         -- then, the editor is switched to visual mode
         {"iW"}, -- then, these keys are executed
         -- in place of keys, you can use one or more functions (no argument
         -- allowed), or both of them
         false
         -- the final argument indicates if this command can be counted (e.g. 3w, 4e,
         -- etc.)
         -- this is true by default and applies to the second set of keys only
       },
       
       word_next = {{"w"}, {"iw"}, false},
       WORD_prev = {{"B"}, {"iWo"}, false,},
       word_prev = {{"b"}, {"iwo"}, false},
       till_next_word = {{"w"}, {"wh"}},
       till_next_WORD = {{"W"}, {"Wh"}},
       till_prev_word = {{"b"}, {"gelowgeo"}},
       till_prev_WORD = {{"B"}, {"gEloWgEo"}},
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
       append_at_cursor = {{}, {"<esc>a"}, false},
       insert_at_cursor = {{}, {"<esc>i"}, false},
       select_inside = {{}, {"i"}, false},
       select_around = {{}, {"a"}, false},
       prev_selection = {{}, {function() require('visual').set_selection(visual.get_history_prev()) end}},
       next_selection = {{}, {function() require('visual').set_selection(visual.get_history_next()) end}},
     },
     -- commands that can be unmapped (for learning new keymaps)
     unmaps = {"W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc"},
     history_size = 50 -- ho many selections we should remember
   }

   if type(options) == "table" then
     return vim.tbl_deep_extend("force", defaults, options)
   else
     return defaults
   end
end

visual.options = with_defaults()


-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
   visual.options = with_defaults(options)
   mappings.unmaps(visual.options)
   mappings.general_mappings(visual.options)
   mappings.partial_mappings(visual.options, "n")
   mappings.partial_mappings(visual.options, "v")
end

return visual
