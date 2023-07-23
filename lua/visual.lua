local visual = {}

local mappings = require("modules.mappings")
local history = require("modules.history")
local extending = require("modules.extending")
local compatibility = require("modules.compatibility")

visual.mappings = mappings
visual.history = history
visual.extending = extending

visual.options = {
	-- commands that will be unmapped from normal or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
	vunmaps = { "A", "I"},
	nunmaps = { "W", "E", "B", "w", "e", "b", "y", "d", "c", "s", "<S-v>", "<C-v>", "gc", ">", "<", "va", "vi"},
	treesitter_textobjects = {
		enable = false, -- only needed if you want to use a different init_key
		init_key = "v", -- the key with which the text object selection start (e.g. vaf, vif have init_key=v)
	},
	history_size = 50, -- how many selections we should remember in the history
	extending = {}, -- options for extending mode
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
		append_at_cursor = "A", -- append at cursor position in visual mode
		insert_at_cursor = "I", -- insert at cursor position in visual mode
		-- visual_inside = "si", -- select inside
		-- visual_around = "sa", -- select around
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
		append_at_cursor = { pre_amend = { "<esc>a" }, post_amend = {}, modes = { "v" } },
		insert_at_cursor = { pre_amend = { "<esc>i" }, post_amend = {}, modes = { "v" } },
		-- visual_inside = { pre_amend = { "<esc>vi" }, post_amend = {}, modes = { "n", "v" } },
		-- visual_around = { pre_amend = { "<esc>va" }, post_amend = {}, modes = { "n", "v" } },
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

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
	if type(options) == "table" then
		visual.options = vim.tbl_deep_extend("force", visual.options, options)
	end
	extending.options = vim.tbl_deep_extend("force", extending.options, visual.options.extending)
	history.history_size = visual.options.history_size
	mappings.unmaps(visual.options, "v")
	mappings.unmaps(visual.options, "n")
	mappings.apply_mappings(visual.options)
	if visual.options.treesitter_textobjects.enable then
		compatibility.treesitter_textobjects(visual.options.treesitter_textobjects.init_key)
	end
end

return visual
