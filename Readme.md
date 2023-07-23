# Visual.nvim

**N.B. This is still in a very experimental stage and mappings will
suddenly change in the next few weeks.** 

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

* Lazy: `{ '00sapo/visual.nvim',   dependencies = { "anuvyklack/keymap-amend.nvim" } }`
* Packer: `use { '00sapo/visual.nvim', requires = { "anuvyklack/keymap-amend.nvim" }`

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


### Example config

Configuration with some change to commands in order to make them compatible:
```lua
{    
  '00sapo/visual.nvim',
  dependencies = { "anuvyklack/keymap-amend.nvim" },
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
    dependencies = { "anuvyklack/keymap-amend.nvim", 'nvim-treesitter/nvim-treesitter' },
    event = "VeryLazy"
}
```

Example with Treesitter text objects. 
```lua
{
    '00sapo/visual.nvim',
    opts = {
        treesitter_textobjects = {
            enable = true,
            init_key = "s" -- instead "vaf", "vif", etc, use "saf", "sif", etc
        }
      },
    dependencies = { "anuvyklack/keymap-amend.nvim", 'nvim-treesitter/nvim-treesitter', "nvim-treesitter/nvim-treesitter-textobjects" },
    event = "VeryLazy"
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
	-- commands that will be unmapped from normal or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
	vunmaps = { "a", "i", "af", "if" },
	nunmaps = { "W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc", ">", "<", "c", "s", "ds", "cs", "yy", "dd" },
	treesitter_textobjects = {
		enable = false,
		init_key = "s",
	},
	history_size = 50, -- how many selections we should remember in the history
    extending = {
        guicursor = "a:hor100",
        keymaps = {
            toggle = "-",
            -- here you can add mappings for extending mode:
            ["x"] = "<S-v>",
            ["X"] = "<C-v>"
            -- you can also map to functions here!
        }
	},
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
		toggle_visual_mode = "v", -- toggle visual mode, here to override possible mappings from other plugins
		find_next = "f", -- select to next char
		find_prev = "F", -- select to previous char
		till_next = "t", -- select till next char
		till_prev = "T", -- select till previous char
		append_at_cursor = "a", -- append at cursor position
		insert_at_cursor = "i", -- insert at cursor position
		visual_inside = "si", -- select inside
		visual_around = "sa", -- select around
		line_visual = "x", -- enter line-visual mode
		block_visual = "<S-x>", -- enter block-visual mode
		delete_char = "y", -- delete char under cursor
		restart_visual = "'", -- collapse the visual selection to the char under cursor
		delete_single_char = "D", -- delete the char under cursor while in visual mode
		replace_single_char = "R", -- replace the char under cursor while in visual mode
		move_down_then_normal = "j", -- move down and enter normal mode
		move_up_then_normal = "k", -- move up and enter normal mode
		move_left_then_normal = "l", -- move left and enter normal mode
		move_right_then_normal = "h", -- move right and enter normal mode
		move_down_visual = "<a-j>", -- move down staying in visual mode
		move_up_visual = "<a-k>", -- move up staying in visual mode
		move_left_visual = "<a-l>", -- move left staying in visual mode
		move_right_visual = "<a-h>", -- move right staying in visual mode
		next_selection = "L", -- surf selection history forward
		prev_selection = "H", -- surf selection history backward
	},
	commands = { -- what each command name does
		WORD_end_next = {
			-- Send the following keys to standard nvim, this can also be a function, or of mix of strings and functions
			-- The `countable` parameter allows each command to be counted.
			-- It is true by default.
			pre_amend = { "<esc>EvgElo", countable = true },
			post_amend = {}, -- Same as above, but run after the amended key (see the `amend` parameter below)
			modes = { "n", "v" }, -- A list of modes where this command will be mappe
			amend = false, -- if `amend` is true, the lhs is run as mapped by other plugins or configs (thanks keys-amend.nvim!)
			-- You can also avoid the keys pre_amend, amend, post_amend, mode, and just use positional arguments. You can also avoid the `amend` parameter and it will default to false. Setting it to true may help avoiding collisions with other plugins.
		},

		word_end_next = { pre_amend = { "<esc>evgelo" }, post_amend = {}, modes = { "n", "v" } },
		WORD_end_prev = { pre_amend = { "<esc>gEvgElo" }, post_amend = {}, modes = { "n", "v" } },
		word_end_prev = { pre_amend = { "<esc>gevgelo" }, post_amend = {}, modes = { "n", "v" } },
		word_start_next = { pre_amend = { "<esc>wvwho" }, post_amend = {}, modes = { "n", "v" } },
		WORD_start_next = { pre_amend = { "<esc>WvWho" }, post_amend = {}, modes = { "n", "v" } },
		word_start_prev = { pre_amend = { "<esc>bviwwho" }, post_amend = {}, modes = { "n", "v" } },
		WORD_start_prev = { pre_amend = { "<esc>BviWWho" }, post_amend = {}, modes = { "n", "v" } },
		toggle_visual_mode = { pre_amend = { "v" }, post_amend = {}, modes = { "n", "v" } },
		find_next = { pre_amend = { "<esc>vf" }, post_amend = {}, modes = { "n", "v" } },
		find_prev = { pre_amend = { "<esc>vF" }, post_amend = {}, modes = { "n", "v" } },
		till_next = { pre_amend = { "<esc>vt" }, post_amend = {}, modes = { "n", "v" } },
		till_prev = { pre_amend = { "<esc>vT" }, post_amend = {}, modes = { "n", "v" } },
		append_at_cursor = { pre_amend = { "<esc>a" }, post_amend = {}, modes = { "n", "v" } },
		insert_at_cursor = { pre_amend = { "<esc>i" }, post_amend = {}, modes = { "n", "v" } },
		visual_inside = { pre_amend = { "<esc>vi" }, post_amend = {}, modes = { "n", "v" } },
		visual_around = { pre_amend = { "<esc>va" }, post_amend = {}, modes = { "n", "v" } },
		prev_selection = {
			pre_amend = {
				function()
					require("visual").history.set_history_prev()
				end,
			},
			post_amend = {},
			modes = { "n", "v" },
		},
		next_selection = {
			pre_amend = {
				function()
					require("visual").history.set_history_next()
				end,
			},
			post_amend = {},
			modes = { "n", "v" },
		},
		line_visual = {
			pre_amend = {
				function()
					require("visual").extending:toggle()
				end,
				"V",
			},
			post_amend = {},
			modes = { "n", "v" },
		},
		block_visual = {
			pre_amend = {
				function()
					require("visual").extending:toggle()
				end,
				"<C-v>",
			},
			post_amend = {},
			modes = { "n", "v" },
		},

		-- mapping applied to normal mode only
		delete_char = { pre_amend = { "x" }, post_amend = {}, modes = { "n" } },
		-- mapping applied to visual mode only
		restart_visual = { pre_amend = { "<esc>v" }, post_amend = {}, modes = { "v" } },
		delete_single_char = { pre_amend = { "<esc>vxgv" }, post_amend = {}, modes = { "v" } },
		replace_single_char = { pre_amend = { "<esc>r" }, post_amend = {}, modes = { "v" } },
		move_down_then_normal = { pre_amend = { "j<esc>" }, post_amend = {}, modes = { "v" } },
		move_up_then_normal = { pre_amend = { "k<esc>" }, post_amend = {}, modes = { "v" } },
		move_left_then_normal = { pre_amend = { "l<esc>" }, post_amend = {}, modes = { "v" } },
		move_right_then_normal = { pre_amend = { "h<esc>" }, post_amend = {}, modes = { "v" } },
		move_down_visual = { pre_amend = { "j" }, post_amend = {}, modes = { "v" } },
		move_up_visual = { pre_amend = { "k" }, post_amend = {}, modes = { "v" } },
		move_left_visual = { pre_amend = { "l" }, post_amend = {}, modes = { "v" } },
		move_right_visual = { pre_amend = { "h" }, post_amend = {}, modes = { "v" } },
	},
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
