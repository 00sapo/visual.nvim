local visual = {}

local mappings = require("modules.mappings")
local history = require("modules.history")
local extending = require("modules.extending")

visual.mappings = mappings
visual.history = history
visual.extending = extending

local function with_defaults(options)
	local defaults = {
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
			next_selection = "L",
			prev_selection = "H",
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
			prev_selection = {
				false,
				{
					function()
						require("visual").history.set_history_prev()
					end,
				},
			},
			next_selection = { false, {
				function()
					require("visual").history.set_history_next()
				end,
			} },
		},
		only_normal_mappings = {
			-- mappings applied to normal mode only:
			-- {lhs, command table}
			line_select = { "x", { {
				function()
					require("visual").extending:toggle()
				end,
				"V",
			}, false } },
			block_select = { "<S-x>", { {
				function()
					require("visual").extending:toggle()
				end,
				"<C-v>",
			}, false } },
			delete_char = { "y", { { "x" }, false } },
		},
		only_visual_mappings = {
			-- mappings applied to visual mode only:
			-- {lhs, {rhs1, rhs2, rhs3}}
			line_select = { "x", { {
				"V",
				function()
					require("visual").extending:toggle()
				end,
			}, false } },
			block_select = { "X", { {
				"<C-v>",
				function()
					require("visual").extending:toggle()
				end,
			}, false } },
			restart_selection = { "'", { false, { "<esc>v" } } },
			delete_single_char = { "D", { { "xgv" }, false } }, -- delete char under cursor
			replace_single_char = { "R", { { "r" }, false } }, -- replace char under cursor
			-- move commands, for extending, you can use -
			move_down_then_normal = { "j", { false, { "j" } } },
			move_up_then_normal = { "k", { false, { "k" } } },
			move_left_then_normal = { "l", { false, { "l" } } },
			move_right_then_normal = { "h", { false, { "h" } } },
			move_down_selecting = { "<a-j>", { { "gvj" }, false } },
			move_up_selecting = { "<a-k>", { { "gvk" }, false } },
			move_left_selecting = { "<a-l>", { { "gvl" }, false } },
			move_right_selecting = { "<a-h>", { { "gvh" }, false } },
			-- if values are strings instead of tables, the value from "commands"
			-- table is taken
		},
		-- commands that can be unmapped (for learning new keymaps)
		unmaps = { "W", "E", "B", "ys", "d", "<S-v>", "<C-v>", "gc", ">", "<" },
		history_size = 50, -- ho many selections we should remember
	}

	if type(options) == "table" then
		if options["extending"] ~= nil then
			extending.setup(options["extending"]) -- this must be done before of setting up mappings
		end
		defaults = vim.tbl_deep_extend("force", defaults, options)
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
	mappings.general_mappings(visual.options)
	mappings.partial_mappings(visual.options, "n")
	mappings.partial_mappings(visual.options, "v")
	history.history_size = visual.options.history_size
end

return visual
