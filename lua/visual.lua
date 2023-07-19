local visual = {}

local mappings = require'modules.mappings'
local history = require'modules.history'

visual.mappings = mappings
visual.history = history

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
       next_selection = "L",
       prev_selection = "H",
     },
     commands = {
       -- what each command name does:
       WORD_next = {
         pre_keys={"W", countable=false}, -- If the command is launched in visual mode, 
         -- the editor is switched to normal mode and these keys are executed.
         -- The editor is not switched to visal mode if pre_keys=nil.
         -- Then, the editor is switched to visual mode
         keys={"iW", countable=false}, -- Then, these keys are executed
         -- in place of keys, you can use one or more functions (no argument
         -- allowed), or both of them.
         -- No switch to visual mode happens if keys=nil.
         -- The `countable` parameters allows each command to be counted.
         -- It is true by default.
       },
       
       word_next = {{"w", countable=false}, {"iw", countable=false}},
       WORD_prev = {{"B", countable=false}, {"iWo", countable=false},},
       word_prev = {{"b", countable=false}, {"iwo", countable=false}},
       till_next_word = {{"w"}, {"who"}},
       till_next_WORD = {{"W"}, {"Who"}},
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
       append_at_cursor = {{"a", countable=false}, nil},
       insert_at_cursor = {{"i", countable=false}, nil},
       select_inside = {nil, {"i", countable=false}},
       select_around = {nil, {"a", countable=false}},
       prev_selection = {{}, {function() require('visual').history.set_history_prev() end}},
       next_selection = {{}, {function() require('visual').history.set_history_next() end}},
     },
     only_normal_mappings = {
       -- mappings applied to normal mode only:
       -- {lhs, {rhs1, rhs2, rhs3}}
       line_select = {"x", {{"<S-v>"}, nil}},
       block_select = {"<S-x>", {{"<C-v>"}, nil}},
       delete_char = {"y", {{"x"}, nil}}
     },
     only_visual_mappings = {
       -- mappings applied to visual mode only:
       -- {lhs, {rhs1, rhs2, rhs3}}
       line_select = {"x", {nil, {"<S-v>"}}},
       block_select = {"X", {nil, {"<C-v>"}}},
       restart_selection = {"'", {nil, {"<esc>v"}}},
       delete_single_char = {"D", {{"xgv"}, nil}}, -- delete char under cursor
       replace_single_char = {"R", {{"r"}, nil}}, -- replace char under cursor
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
     -- commands that can be unmapped (for learning new keymaps)
     unmaps = {"W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc", ">", "<"},
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
   history.history_size = visual.options.history_size
end

return visual
