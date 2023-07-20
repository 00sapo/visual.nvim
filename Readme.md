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
standard nvim, including normal and insert modes, until `-` is pressed again. For remapping keys in this special
mode, use the table `extending` (see below). You can also customize the cursor in
this mode to visualize it.


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
        WORD_end_next = "E", -- select next WORD (punctuation included), cursor at end, previous space included
        word_end_next = "e", -- same as E but without punctuation
        WORD_end_prev = "gE", -- same as E but for previous words
        word_end_prev = "ge", -- same as e but for previous words
        WORD_start_next = "W", -- select next word including next its space, cursor at beginning, with punctuation
        word_start_next = "w", -- same as W but without punctuation
        WORD_start_prev = "B", -- select previous WORD including its next space, with punctuation, cursor at beginnning
        word_start_prev = "b", -- same as B but without punctuation
        find_next = "f", -- select to next char
        find_prev = "F", -- select to previous char
        till_next = "t", -- select till next char
        till_prev = "T", -- select till previous char
        append_at_cursor = "a", -- append at cursor position
        insert_at_cursor = "i", -- insert at cursor position
        select_inside = "si", -- select inside
        select_around = "sa", -- select around
        extending_mode = "-",
        next_selection = "L", -- under work
        prev_selection = "H", -- under work
    },
    commands = {
        -- what each command name does:
        WORD_end_next = {
            pre_keys = { "E", countable = true },
            -- The editor is switched to normal mode and these keys are executed.
            -- The editor is not switched to normal mode if pre_keys=nil.
            keys = { "gElo", countable = false },
            -- Then, the editor is switched to visual mode and these keys are executed
            -- In place of keys, you can use one or more functions (no argument
            -- allowed), or both of them.
            -- No switch to visual mode happens if keys=nil.
            -- The `countable` parameters allows each command to be counted.
            -- It is true by default.
        },

        word_end_next = { { "e" }, { "gelo", countable = false } },
        WORD_end_prev = { { "gE" }, { "gElo", countable = false } },
        word_end_prev = { { "ge" }, { "gelo", countable = false } },
        word_start_next = { { "w" }, { "who", countable = false } },
        WORD_start_next = { { "W" }, { "Who", countable = false } },
        word_start_prev = { { "b" }, { "iwwho", countable = false } },
        WORD_start_prev = { { "B" }, { "iWWho", countable = false } },
        find_next = { {}, { "f" } },
        find_prev = { {}, { "F" } },
        till_next = { {}, { "t" } },
        till_prev = { {}, { "T" } },
        append_at_cursor = { false, { "<esc>a", countable = false } },
        insert_at_cursor = { false, { "<esc>i", countable = false } },
        select_inside = { false, { "<esc>vi", countable = false } },
        select_around = { false, { "<esc>va", countable = false } },
        extending_mode = { false, {
            function()
                require("visual").extending:toggle()
            end,
        } },
        prev_selection = { false, {
            function()
                require("visual").history.set_history_prev()
            end,
        } },
        next_selection = { false, {
            function()
                require("visual").history.set_history_next()
            end,
        } },
    },
    only_normal_mappings = {
        -- mappings applied to normal mode only:
        -- {lhs, command table}
        line_select = { "x", { { "<S-v>" }, false} },
        block_select = { "<S-x>", { { "<C-v>" }, false} },
        delete_char = { "y", { { "x" }, false } },
    },
    only_visual_mappings = {
        -- mappings applied to visual mode only:
        -- {lhs, {rhs1, rhs2, rhs3}}
        line_select = { "x", { false, { "<S-v>" } } },
        block_select = { "X", { false, { "<C-v>" } } },
        restart_selection = { "'", { false, { "<esc>v" } } },
        delete_single_char = { "D", { { "xgv" }, false } }, -- delete char under cursor
        replace_single_char = { "R", { { "r" }, false } }, -- replace char under cursor
        -- move commands, for extending, you can use -
        move_down_then_normal = {"j", {false, {"<esc>j"}}},
        move_up_then_normal = {"k", {false, {"<esc>k"}}},
        move_left_then_normal = {"l", {false, {"<esc>l"}}},
        move_right_then_normal = {"h", {false, {"<esc>h"}}},
        -- if values are strings instead of tables, the value from "commands"
  -- table is taken
    },
    -- commands that can be unmapped (for learning new keymaps)
    unmaps = { "W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc", ">", "<" },
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
