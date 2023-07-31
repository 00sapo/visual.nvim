local history = {}
history.repeat_mapping_name = 'repeat_command'
history.last_command = nil
history.selection_history = {}
history.cur_history_idx = 0

local utils = require('modules.utils')

function history.setup(opts)
	history.history_size = opts.history_size
end

function history.run_last_command(original)
  local make_rhs = require('modules.mappings').make_rhs
	if history.last_command == nil then
		return
	end
	local f = make_rhs(history.last_command, true)
	Vdbg("Running last command: ")
	Vdbg(history.last_command)
	return f(original)
end


-- selection_history is a simple stack with push/pop methods and maximum size
-- defined by history.history_size

-- Function to push a new selection into the history
-- @param selection: The selection to be added to the history
function history:push(selection)
    -- Check if the current selection is identical to the one at the cur_history_idx
    if history.selection_history[history.cur_history_idx] == selection then
        return
    end
    -- print("pushing")
    -- Check if the history is already full
    if #history.selection_history == history.history_size then
        -- Remove the oldest selection
        table.remove(history.selection_history, 1)
    end
    -- Check if current history index is less than the size of selection history
    if history.cur_history_idx < #history.selection_history then
        -- Remove all elements after the current history index
        for i = history.cur_history_idx + 1, #history.selection_history do
            table.remove(history.selection_history, i)
        end
        -- Insert the new selection at the current history index
        table.insert(history.selection_history, history.cur_history_idx, selection)
    else
        -- Add the new selection to the history
        table.insert(history.selection_history, selection)
    end
    -- Update the current history index
    history.cur_history_idx = #history.selection_history
end

-- Function to pop the most recent selection from the history
-- @return The most recent selection, or nil if the history is empty
function history:pop()
	-- Check if the history is empty
	if #history.selection_history == 0 then
		-- Return nil, as there is no selection to pop
		return nil
	end
	-- Get the most recent selection
	local selection = history.selection_history[history.cur_history_idx]
	-- Remove the most recent selection from the history
	table.remove(history.selection_history, history.cur_history_idx)
	-- Update the current history index
	history.cur_history_idx = #history.selection_history
	-- Return the popped selection
	return selection
end

-- Function to move back in the history
-- @return The previous selection in the history, or nil if there is no previous selection
function history:back()
	-- Check if there is a previous selection
	if history.cur_history_idx <= 1 then
		-- Return nil, as there is no previous selection
		return nil
	end
	-- Decrement the current history index
	history.cur_history_idx = history.cur_history_idx - 1
	-- Return the previous selection
	return history.selection_history[history.cur_history_idx]
end

-- Function to move forward in the history
-- @return The next selection in the history, or nil if there is no next selection
function history:forward()
	-- Check if there is a next selection
	if history.cur_history_idx >= #history.selection_history then
		-- Return nil, as there is no next selection
		return nil
	end
	-- Increment the current history index
	history.cur_history_idx = history.cur_history_idx + 1
	-- Return the next selection
	return history.selection_history[history.cur_history_idx]
end

function history.set_selection(selection)
  if selection ~= nil then
    utils.enter("n")
    -- print(vim.inspect(selection))
    vim.fn.cursor(selection[1][2], selection[1][3])
    utils.enter("v")
    vim.fn.cursor(selection[2][2], selection[2][3])
  end
end

function history.set_history_next()
	history.set_selection(history:forward())
end

function history.set_history_prev()
	history.set_selection(history:back())
end

return history
