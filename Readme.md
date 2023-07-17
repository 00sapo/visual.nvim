# Visual.nvim

First select, then edit. This should be the way.

If you have been tempted by Kakoune and Helix editors, this may be your new plugin!

## Usage

Just install it using your preferred package manager.

* Lazy: `{ '00sapo/visual.nvim' }`
* Packer: `use { '00sapo/visual.nvim' }`

## How it works

The plugin remap keys so that they select text objects/regions before you can type the
edit command. It's basically like having a `v` key automatically typed before any
command. Consequently, some keymaps already available will still be used, especially `o`
in visual mode will be your new companion key!

## Keymaps

The plugin is highly customizable. It maps commands to keymaps, and you cna define new
commands or edit the existing ones. The following is the default set-up. Read the
comments to understand how to modify it.

Feel free to suggest new default keybindings in the issues!

```lua
 mappings = {
   -- a list of command names, mapped to a lhs of mapping for visual and
   -- normal mode
   WORD_next = "w", -- select next WORD (punctuation included)
   word_next = "e", -- select next word (no punctuation included)
   WORD_prev = "z", -- select previous WORD
   word_prev = "b", -- select previous word
   extend_word_end = "-e", -- extend until end of word
   extend_word_prev = "-b", -- extend current selection until previous begin of word
   extend_word_next = "-w", -- extend current selection until next word
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
   extend_word_end = {{}, {"gve"}},
   extend_word_prev = {{}, {"gvb"}},
   extend_word_next = {{}, {"gvw"}},
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
```

# TODO

* Selection history is being developed
* Some commands misbehave the selection history (`gv`). For instance, when using `R` and
  `D` in visual mode (replace and delete char at cursor position), the selection is
  lost; the history of selections will solve it
