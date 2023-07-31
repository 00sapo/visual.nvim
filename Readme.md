# Visual.nvim

**N.B. This is still in a very experimental stage and mappings will
suddenly change in the next few weeks.** 

### serendipity
**noun,  formal**
UK  */ˌser.ənˈdɪp.ə.ti/*
US  */ˌser.ənˈdɪp.ə.t̬i/*

_the fact of finding interesting or valuable things by chance_

## What is this
In nvim, you do `c3w`. Ah no! It was wrong, let's retry: `uc5w`... wooops! Sorry, it
is still wrong: `uc6w`!

In Kakoune (which inspired Helix), you do the opposite: `3w`. First select 3
words, then you see you still need three words, so `3w`. Then finally `d` for
deleting.

In `visual.nvim`, this actually becomes `3wv3wd`, with the `v` used for
"refining" selections. If you do not need to adjust the selection, `3wd` is all
you need. The magic here is that `visual.nvim` puts you in a special mode named
"serendipity" in which you can use some normal commands but also some visual commands.
This allows you to have a preview of what your edit command will modify, so that you
can occasionally change the selection by entering the visual mode.

First select, then edit. This should be the way.

If you have been tempted by Kakoune and Helix editors, this may be your new plugin!

## Features

* Selection first mode
* New "serendipity" mode: discover motion errors by chance!
* Surrounding commands (change, delete, add) that operate over selections
* Repeat motions

## Usage

Just install it using your preferred package manager.

* Lazy: `{ '00sapo/visual.nvim' }`
* Packer: `use { '00sapo/visual.nvim' }`

### Usage

Motion commands such as `w`, `e`, `b`, `ge`, `f`, `t` and their punctuation-aware alternatives
`W`, `E`, `B`, `gE`, `F`, `T` behave the same as vim (or are supposed so), but also put you in
"serendipity" mode.

Once you are in serendipity mode, you can modify text (`c`, `x`, `i`, `a`) as if you were in normal mode. `d` and `y` will work as in visual mode. With `,`, you can repeat the last motion selection.
Serendipity mode is built around the nvim's visual mode, so you can use all
visual commands if they don't interfer with your config.
From serendipity mode, you can enter visual mode with `v`, `<S-v>`, `<C-v>`. You can
also switch between visual and serendipity mode with `-`. 
From serendipity mode, `<esc>` will lead you to normal mode.

Note that motion commands in visual mode are different from normal mode.
Serendipity mode emulates normal mode for motion commands!

Remember using `o` to move the cursor to the other end of the visual/serendipity
selection when needed.

Selection of text objects is possible as in usual nvim with `i<text object>` and `a<text object>` in visual mode, thus becoming `va` and `vi` from normal mode, similarly to Helix's `mi` and `ma`. From serendipity mode, since `i` and `a` are mapped to `append` and `insert`, they become `I` and `A`, (or still `vi` and `va`). Note that `I` and `A` do not currently support tree-sitter objects (that are instead supported by `va` and `vi`).

Visual.nvim also offers surrounding commands with `sd`, `sc`, and `sa` (delete, change, add).

Visual.nvim still does not support macros and reapeats (while repeating selections
is supported with `,`, the `.`-repeat is not). You can still use the commands
`:VisualDisable` and `:VisualEnable` for using macros with standard nvim
commands.


### Example config

Configuration with some change to commands in order to make them compatible:
```lua
{    
  '00sapo/visual.nvim',
  config = function()
    require('visual').setup({
    commands = {
      move_up_then_normal = { amend = true },
      move_down_then_normal = { amend = true },
      move_right_then_normal = { amend = true },
      move_left_then_normal = { amend = true },
    },
  } )
  end,
  event = "VeryLazy", -- this is for making sure our keymaps are applied after the others: we call the previous mapppings, but other plugins/configs usually not!
}
```

Example with Treesitter incremental selection
```lua
{
    '00sapo/visual.nvim',
    config = function ()
        require('nvim-treesitter.configs').setup { 
            incremental_selection = { 
                enable = true,
                keymaps = {
                    init_selection = "<c-.>",
                    node_incremental = "<c-.>",
                    scope_incremental = "<c-,>",
                    node_decremental = "<c-/>",
                }
            } 
        }
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = "VeryLazy"
}
```


## Keymaps

The plugin is highly customizable. It maps commands to keymaps, and you can define new
commands or edit the existing ones. The following is the default set-up. Read the
comments to understand how to modify it.

Feel free to suggest new default keybindings in the issues!

```lua
 require('visual').setup{
	-- commands that will be unmapped from serendipity, normal, or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
	sdunmaps = {},
	vunmaps = {},
	nunmaps = { "W", "E", "B", "w", "e", "b", "y", "d", "c", "s", "gc", ">", "<" },
	history_size = 50, -- how many selections we should remember in the history
	serendipity = {}, -- options for serendipity mode
	mappings = {
		-- a list of command names and of their key-maps; what each command does is defined below
		WORD_end_next = "E", -- select next WORD (punctuation included), cursor at end, previous space included
		word_end_next = "e", -- same as E but without punctuation
		WORD_end_prev = "gE", -- same as E but for previous words
		word_end_prev = "ge", -- same as e but for previous words
		WORD_start_next = "W", -- select next word including next its space, cursor at beginning, with punctuation
		word_start_next = "w", -- same as W but without punctuation
		WORD_start_prev = "B", -- select previous WORD including its next space, with punctuation, cursor at beginnning
		word_start_prev = "b", -- same as B but without punctuation
		toggle_serendipity = "-", -- toggle visual mode, here to override possible mappings from other plugins
		find_next = "f", -- select to next char
		find_prev = "F", -- select to previous char
		till_next = "t", -- select till next char
		till_prev = "T", -- select till previous char
		append_at_cursor = "a", -- append at cursor position in visual mode
		insert_at_cursor = "i", -- insert at cursor position in visual mode
		sd_inside = "I", -- select inside from serendipity mode
		sd_around = "A", -- select around from serendipity mode
		-- line_visual = "x", -- enter line-visual mode
		-- block_visual = "<S-x>", -- enter block-visual mode
		-- delete_char = "y", -- delete char under cursor
		restart_visual = "'", -- collapse the visual selection to the char under cursor
		delete_single_char = "x", -- delete the char under cursor while in visual mode
		replace_single_char = "r", -- replace the char under cursor while in visual mode
		surround_change = "sc", -- change chars at the extremes of the selection
		surround_add = "sa", -- insert chars at the extremes of the selection
		surround_delete = "sd", -- delete chars at the extremes of the selection
		increase_indent = ">", -- increase indent in visual mode
		decrease_indent = "<", -- decrease indent in visual mode
		increase_indent_sd = ">", -- increase indent in serendipity mode
		decrease_indent_sd = "<", -- decrease indent in serendipity mode
		repeat_command = ",",
		-- next_selection = "L", -- surf selection history forward (not working for now)
		-- prev_selection = "H", -- surf selection history backward (not working for now)
	},
	commands = { -- what each command name does
		-- 	example_command = {
		-- 		-- Send the following keys to standard nvim, this can also be a function, or of mix of strings and functions
		-- 		-- The `countable` parameter allows each command to be counted.
		-- 		-- It is true by default and can be specified at the whole command level or at each inner-level.
		-- 		-- In this second case, you need to use `rhs` key for the command value (string or function).
		-- 		-- The outer level has precedence on the inner level.
		-- 		countable = true,
		-- 		pre_amend = {
		-- 			{ rhs = "<esc>v", countable = false },
		-- 			{ rhs = "E<sdi>", countable = true },
		-- 		},
		-- 		-- <sdi> is a special code meaning "enter serendipity mode"
		-- 		-- similarly, you can use <sde> and <sdt> for exit and toggle serendipity mode
		-- 		post_amend = {}, -- Same as above, but run after the amended key (see the `amend` parameter below)
		-- 		modes = { "n", "sd" }, -- A list of modes where this command will be mapped; "sd" is serendipity mode
		-- 		amend = false, -- if `amend` is true, the lhs is run as mapped by other plugins or configs (thanks keys-amend.nvim!)
		-- 		-- You can also avoid the keys pre_amend, amend, post_amend, mode, and just use positional arguments. You can also avoid the `amend` parameter and it will default to false. Setting it to true may help avoiding collisions with other plugins.
		-- 	},

		word_end_next = {
			pre_amend = {
				motions.word_start_next,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_end_next = {
			pre_amend = {
				motions.WORD_start_next,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_end_prev = {
			pre_amend = {
				motions.word_start_prev,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_end_prev = {
			pre_amend = {
				motions.WORD_start_prev,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_start_next = {
			pre_amend = {
				motions.word_start_next,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_start_next = {
			pre_amend = {
				motions.WORD_start_next,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_start_prev = {
			pre_amend = {
				motions.word_start_prev,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_start_prev = {
			pre_amend = {
				motions.WORD_start_prev,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		toggle_serendipity = { pre_amend = { "<sdt>" }, post_amend = {}, modes = { "n", "sd", "v" }, countable = false },
		find_next = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "f" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		find_prev = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "F" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_next = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "t" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_prev = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "T" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		repeat_command = {
			pre_amend = { history.run_last_command },
			post_amend = {},
			modes = { "n", "sd", "v" },
		},
		prev_selection = {
			pre_amend = {
				history.set_history_prev,
			},
			post_amend = {},
			modes = { "n", "v", "sd" },
		},
		next_selection = {
			pre_amend = {
				history.set_history_next,
			},
			post_amend = {},
			modes = { "n", "v", "sd" },
		},
		sd_around = { pre_amend = { "<esc>", "va<sdi>" }, post_amend = {}, modes = { "sd" }, countable = false },
		sd_inside = { pre_amend = { "<esc>", "vi<sdi>" }, post_amend = {}, modes = { "sd" }, countable = false },
		append_at_cursor = { pre_amend = { "<esc>", "a" }, post_amend = {}, modes = { "sd" }, countable = false },
		insert_at_cursor = { pre_amend = { "<esc>", "i" }, post_amend = {}, modes = { "sd" }, countable = false },
		surround_delete = {
			pre_amend = { '<cmd>lua require("visual").surround.delete()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_add = {
			pre_amend = { '<cmd>lua require("visual").surround.add()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_change = {
			pre_amend = { '<cmd>lua require("visual").surround.change()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		restart_visual = {
			pre_amend = { "<esc>", "<sde>", "<sdi>" },
			post_amend = {},
			modes = { "sd" },
			countable = false,
		},
		delete_single_char = {
			pre_amend = { "<esc>", "xgv<sdi>" },
			post_amend = {},
			modes = { "sd" },
			countable = false,
		},
		replace_single_char = { pre_amend = { "<esc>", "r" }, post_amend = {}, modes = { "sd" }, countable = false },
		decrease_indent = { pre_amend = { "<gv" }, post_amend = {}, modes = { "v" } },
		increase_indent = { pre_amend = { ">gv" }, post_amend = {}, modes = { "v" } },
		decrease_indent_sd = { pre_amend = { "<gv<sdi>" }, post_amend = {}, modes = { "sd" } },
		increase_indent_sd = { pre_amend = { ">gv<sdi>" }, post_amend = {}, modes = { "sd" } },
	},
}
```

# Testing

* `curl https://raw.githubusercontent.com/00sapo/visual.nvim/main/test/init.lua -o /tmp/visual.nvim-test.lua`
* `nvim -u /tmp/visual.nvim-test.lua <file>`

# TODO

* Make surrounding commands re-select the remaining text
* Selection history is being developed
* Experiment with `vim-visual-multi`
