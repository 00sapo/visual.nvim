-- if vim.fn.has("nvim-0.7.0") == 0 then
--   vim.api.nvim_err_writeln("visual.nvim requires at least nvim-0.7.0.1")
--   return
-- end

-- make sure this file is loaded only once
if vim.g.loaded_visual == 1 then
  return
end
vim.g.loaded_visual = 1

local visual = require("visual")
local m = visual.options.mappings
local nm = visual.options.only_normal_mappings
local vm = visual.options.only_visual_mappings
local c = visual.options.commands
local u = visual.options.unmaps

-- general mappings
for k, v in pairs(m) do
   vim.keymap.set('n', v, visual.get_mapping_func(c[k], "n"), { noremap = true, silent = true })
   vim.keymap.set('v', v, visual.get_mapping_func(c[k], "v"), { noremap = true, silent = true })
 end

 -- only normal mappings
for k, v in pairs(nm) do
   vim.keymap.set('n', v[1], visual.get_mapping_func({{}, v[2]}, "n"), { noremap = true, silent = true })
 end

 -- only visual mappings
for k, v in pairs(vm) do
   vim.keymap.set('v', v[1], visual.get_mapping_func({{}, v[2]}, "v"), { noremap = true, silent = true })
 end

 -- unmappings
 local nothing = function() end
for k, v in pairs(u) do
   vim.keymap.set('n', v, nothing, { silent = true })
 end
