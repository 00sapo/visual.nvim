# Visual.nvim

In nvim, you do `c3w`. Ah no! It was wrong, let's retry: `uc5w`... wooops! Sorry, it
is still wrong: `uc6w`!

In Kakoune (which inspired Helix), you do the opposite: `3w`. First select 3
words, then you see you still need three words, so `3w`. Then finally `d` for
deleting. In `visual.nvim` (and Helix), this actually becomes `-3w3wd`, with the `-`
used for "extending" selections.

First select, then edit. This should be the way.

If you have been tempted by Kakoune and Helix editors, this may be your new plugin!


## Usage

Just install it using your preferred package manager.

* Lazy: `{ '00sapo/visual.nvim' }`
* Packer: `use { '00sapo/visual.nvim' }`

### Helix vs Visual.nvim

Most of the ideas of this plugin are taken from Helix.

Basic commands such as `w`, `e`, `b`, `ge` and thei punctuation-aware alternatives
`W`, `E`, `B`, `gE` behave the same as in Helix.

`x`, similarly to Helix, enters linewise selection. `<S-x>` enters block-wise
selection. To keep the same key in normal and visual mode, `x` and `<S-x>` do the same
in normal mode as well. Consequently, single-char-deletion is mapped to `y`. Yanking
one line is then `xy` and deleting one line is `xd`, as opposed to nvim `yy` and
`dd`.

Collapsing the selection and flipping cursor is already provided by
nvim with `v` (which toggles visual mode) and `o` (which flips the cursor
position).

Selection of text objects is possible with `si<text object>` and `sa<text object>` in both visual and normal mode, similarly to Helix's `mi` and `ma`.

While in visual mode, it's also possible to delete or replace one single char at the
cursor position with `R` and `A`. Moreover, differently from nvim, the `i` and `a`
keys always insert and append at the cursor position (in nvim, they operate at the
extremes of the selection).

The Helix's selection mode, that is the usual Vim's visual mode, can be toggled to
`-`. When pressing `-`, both in visual or normal mode, all keys are passed to
visual mode and interpreted by standard nvim.


### Suggested config

Example with Lazy and Treesitter incremental selection
```lua
{
    '00sapo/visual.nvim',
    config = function ()
        require('nvim-treesitter.configs').setup { 
            incremental_selection = { 
                enable = true,
                keymaps = {
                    init_selection = "gn",
                    node_incremental = "|",
                    scope_incremental = "_",
                    node_decremental = "\"",
                }
            } 
        }
        -- in lunarvim:
        -- lvim.builtin.treesitter.incremental_selection = {
        --     enable = true,
        --     keymaps = {
        --         init_selection = "gn",
        --         node_incremental = "|",
        --         scope_incremental = _;",
        --         node_decremental = "\"",
        --     }
        -- }
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' }
}
```

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
 require('visual').setup{
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
       delete_single_char = {"D", {"d"}}, -- delete char under cursor
       replace_single_char = {"R", {"r"}}, -- replace char under cursor
      -- if they are strings, use the value from "commands" table
       extend_word_end = "-e", -- extend until end of word
       extend_word_prev = "-b", -- extend current selection until previous begin of word
       extend_word_next = "-w", -- extend current selection until next word
       extend_find_next = "-f", -- extend current selection to next char
       extend_find_prev = "-F", -- extend current selection to previous char
       extend_till_next = "-t", -- extend current selection till next char
       extend_till_prev = "-T", -- extend current selection till previous char
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
     },
     -- commands that can be unmapped (for learning new keymaps)
     unmaps = {"W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc"},
}
```

# TODO

* Selection history is being developed
* Some commands misbehave the selection history (`gv`). For instance, when using `R` and
  `D` in visual mode (replace and delete char at cursor position) or `gcc`, `>`, `<`, the selection is
  lost; the history of selections will solve it
* History of selections will also improve commands for extending current selection
* History of selections will allow to edit/append/remove surrounding chars
  without additional plugins
* History of commands will allow to repeat commands, including edits
* Experiment with `vim-visual-multi`
* Improve commands for extending selections
