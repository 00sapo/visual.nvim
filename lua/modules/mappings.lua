local mappings = {}

local function apply_key(key, count)
  if type(key) == 'function' then
    key()
  elseif type(key) == 'string' then
    if count >= 1 then 
      key = count .. key
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
  end
end

function get_mapping_func(keys, mode)
  local function f()
    if mode == 'v' then
      -- Save current selection to history
      local selection = {
        vim.fn.getpos('v'), vim.fn.getpos('.')
      }
      -- visual.push_history(selection)

      -- Enter normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', false)

      -- pre-visual keys
      for _, key in pairs(keys[1]) do
        apply_key(key, 0)
      end
    end
    -- Enter visual mode
    vim.api.nvim_feedkeys('v', 'n', false)

    -- visual keys
    for _, key in pairs(keys[2]) do
      if #keys == 2 or keys[3] then
        apply_key(key, vim.v.count)
      else
        apply_key(key, 0)
      end
    end
  end
  return f
end

-- general mappings
function mappings.general_mappings(opts)
  local m = opts.mappings
  local c = opts.commands
  for k, v in pairs(m) do
     vim.keymap.set('n', v, get_mapping_func(c[k], "n"), { noremap = true, silent = true })
     vim.keymap.set('v', v, get_mapping_func(c[k], "v"), { noremap = true, silent = true })
   end
 end

 -- only normal mappings
 function mappings.only_normal_mappings(opts)
  local nm = opts.only_normal_mappings
  for k, v in pairs(nm) do
     vim.keymap.set('n', v[1], get_mapping_func({{}, v[2]}, "n"), { noremap = true, silent = true })
   end
 end

 -- only visual mappings
function mappings.only_visual_mappings(opts)
  local vm = opts.only_visual_mappings
  for k, v in pairs(vm) do
     vim.keymap.set('v', v[1], get_mapping_func({{}, v[2]}, "v"), { noremap = true, silent = true })
   end
 end

 -- unmappings
 function mappings.unmaps(opts)
  local u = opts.unmaps
  local nothing = function() end
  for k, v in pairs(u) do
    vim.keymap.set('n', v, nothing, { silent = true })
  end
end

 return mappings
