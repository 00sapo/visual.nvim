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
			select_inside = "si", -- select inside
			select_around = "sa", -- select around
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
		commands = {
			-- what each command name does:
			WORD_end_next = {
				-- Send the following keys to standard nvim, this can also be a function, or of mix of strings and functions
				-- The `countable` parameter allows each command to be counted.
				-- It is true by default.
				pre_amend = { "<esc>EvgElo", countable = true },
				post_amend = {}, -- Same as above, but run after the amended key (see the `amend` parameter below)
				modes = { "n", "v" }, -- A list of modes where this command will be mappe
				amend = false, -- if `amend` is true, the lhs is run as mapped by other plugins or configs (thanks keys-amend.nvim!)
				-- You can also avoid the keys pre_amend, amend, post_amend, mode, and just use positional arguments. You can also avoid the `amend` parameter and it will default to false.
			},

			word_end_next = { { "<esc>e" }, { "vgelo", countable = false }, { "n", "v" } },
			WORD_end_prev = { { "<esc>gE" }, { "vgElo", countable = false }, { "n", "v" } },
			word_end_prev = { { "<esc>ge" }, { "vgelo", countable = false }, { "n", "v" } },
			word_start_next = { { "<esc>w" }, { "vwho", countable = false }, { "n", "v" } },
			WORD_start_next = { { "<esc>W" }, { "vWho", countable = false }, { "n", "v" } },
			word_start_prev = { { "<esc>b" }, { "viwwho", countable = false }, { "n", "v" } },
			WORD_start_prev = { { "<esc>B" }, { "viWWho", countable = false }, { "n", "v" } },
			find_next = { { "<esc>" }, { "vf" }, { "n", "v" } },
			find_prev = { { "<esc>" }, { "vF" }, { "n", "v" } },
			till_next = { { "<esc>" }, { "vt" }, { "n", "v" } },
			till_prev = { { "<esc>" }, { "vT" }, { "n", "v" } },
			append_at_cursor = { {}, { "<esc>a", countable = false }, { "n", "v" } },
			insert_at_cursor = { {}, { "<esc>i", countable = false }, { "n", "v" } },
			select_inside = { {}, { "<esc>vi", countable = false }, { "n", "v" } },
			select_around = { {}, { "<esc>va", countable = false }, { "n", "v" } },
			prev_selection = {
				{},
				{
					function()
						require("visual").history.set_history_prev()
					end,
				},
				{ "n", "v" },
			},
			next_selection = {
				{},
				{
					function()
						require("visual").history.set_history_next()
					end,
				},
				{ "n", "v" },
			},
			line_select = {
				{
					"V",
					function()
						require("visual").extending:toggle()
					end,
				},
				{},
				{ "n", "v" },
			},
			block_select = {
				{
					"<C-v>",
					function()
						require("visual").extending:toggle()
					end,
				},
				{},
				{ "n", "v" },
			},

			-- mapping applied to normal mode only
			delete_char = { { "x" }, {}, { "n" } },
			-- mapping applied to visual mode only
			restart_selection = { {}, { "<esc>v" }, { "v" } },
			delete_single_char = { { "<esc>vxgv" }, {}, { "v" } }, -- delete char under cursor
			replace_single_char = { { "<esc>r" }, {}, { "v" } }, -- replace char under cursor
			-- move commands, for extending, you can use -
			move_down_then_normal = { {}, { "vj" }, { "v" } },
			move_up_then_normal = { {}, { "vk" }, { "v" } },
			move_left_then_normal = { {}, { "vl" }, { "v" } },
			move_right_then_normal = { {}, { "vh" }, { "v" } },
			move_down_selecting = { { "<esc>gvj" }, {}, { "v" } },
			move_up_selecting = { { "<esc>gvk" }, {}, { "v" } },
			move_left_selecting = { { "<esc>gvl" }, {}, { "v" } },
			move_right_selecting = { { "<esc>gvh" }, {}, { "v" } },
			-- if values are strings instead of tables, the value from "commands"
			-- table is taken
		},
	}

	if type(options) == "table" then
		defaults = vim.tbl_deep_extend("force", defaults, options)
		vim.tbl_deep_extend("force", extending.options, defaults.extending)
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
