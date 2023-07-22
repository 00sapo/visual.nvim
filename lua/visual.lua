local visual = {}

local mappings = require("modules.mappings")
local history = require("modules.history")
local extending = require("modules.extending")

visual.mappings = mappings
visual.history = history
visual.extending = extending

local function with_defaults(options)
	local defaults = {
		-- commands that will be unmapped from normal mode (e.g. for forcing you learning new keymaps)
		unmaps = { "W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc", ">", "<" },
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

			word_end_next = { { "<esc>evgelo" }, {}, { "n", "v" } },
			WORD_end_prev = { { "<esc>gEvgElo" }, {}, { "n", "v" } },
			word_end_prev = { { "<esc>gevgelo" }, {}, { "n", "v" } },
			word_start_next = { { "<esc>wvwho" }, {}, { "n", "v" } },
			WORD_start_next = { { "<esc>WvWho" }, {}, { "n", "v" } },
			word_start_prev = { { "<esc>bviwwho" }, {}, { "n", "v" } },
			WORD_start_prev = { { "<esc>BviWWho" }, {}, { "n", "v" } },
			find_next = { { "<esc>vf" }, {}, { "n", "v" } },
			find_prev = { { "<esc>vF" }, {}, { "n", "v" } },
			till_next = { { "<esc>vt" }, {}, { "n", "v" } },
			till_prev = { { "<esc>vT" }, {}, { "n", "v" } },
			append_at_cursor = { { "<esc>a" }, {}, { "n", "v" } },
			insert_at_cursor = { { "<esc>i" }, {}, { "n", "v" } },
			visual_inside = { { "<esc>vi" }, {}, { "n", "v" } },
			visual_around = { { "<esc>va" }, {}, { "n", "v" } },
			prev_selection = {
				{
					function()
						require("visual").history.set_history_prev()
					end,
				},
				{},
				{ "n", "v" },
			},
			next_selection = {
				{
					function()
						require("visual").history.set_history_next()
					end,
				},
				{},
				{ "n", "v" },
			},
			line_visual = {
				{
					function()
						require("visual").extending:toggle()
					end,
					"V",
				},
				{},
				{ "n", "v" },
			},
			block_visual = {
				{
					function()
						require("visual").extending:toggle()
					end,
					"<C-v>",
				},
				{},
				{ "n", "v" },
			},

			-- mapping applied to normal mode only
			delete_char = { { "x" }, {}, { "n" } },
			-- mapping applied to visual mode only
			restart_visual = { { "<esc>v" }, {}, { "v" } },
			delete_single_char = { { "<esc>vxgv" }, {}, { "v" } },
			replace_single_char = { { "<esc>r" }, {}, { "v" } },
			move_down_then_normal = { { "j<esc>" }, {}, { "v" } },
			move_up_then_normal = { { "k<esc>" }, {}, { "v" } },
			move_left_then_normal = { { "l<esc>" }, {}, { "v" } },
			move_right_then_normal = { { "h<esc>" }, {}, { "v" } },
			move_down_visual = { { "j" }, {}, { "v" } },
			move_up_visual = { { "k" }, {}, { "v" } },
			move_left_visual = { { "l" }, {}, { "v" } },
			move_right_visual = { { "h" }, {}, { "v" } },
		},
	}

	if type(options) == "table" then
		defaults = vim.tbl_deep_extend("force", defaults, options)
		extending.options = vim.tbl_deep_extend("force", extending.options, defaults.extending)
	end
	history.history_size = defaults.history_size
	return defaults
end

visual.options = with_defaults()

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
	visual.options = with_defaults(options)
	mappings.unmaps(visual.options)
	mappings.apply_mappings(visual.options)
	history.history_size = visual.options.history_size
end

return visual
