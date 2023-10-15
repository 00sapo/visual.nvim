-- download and run with nvim -u init.lua <file to edit>
local lazypath = vim.fn.stdpath("run") .. "/visual.nvim-test/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

vim.cmd("hi Visual guifg=black guibg=lightyellow ctermfg=black ctermbg=lightyellow")

require("lazy").setup({
	{
		"00sapo/visual.nvim",
		opts = { treesitter_textobjects = true },
		dependencies = { "nvim-treesitter", "nvim-treesitter-textobjects", "leap.nvim", "flit.nvim" },
		event = "VeryLazy",
	},
	-- uncomment the followings for testing cmp sources
	-- { "neovim/nvim-lspconfig" },
	-- { "hrsh7th/cmp-nvim-lsp" },
	-- { "L3MON4D3/LuaSnip" },
	-- { "saadparwaiz1/cmp_luasnip" },
	-- { "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-buffer" },
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				-- use one of the following for snippets
				-- snippet = {
				-- 	expand = function(args)
				-- 		-- vim.fn["vsnip#anonymous"](args.body)
				-- 		require("luasnip").lsp_expand(args.body) -- recommended
				-- 		-- require('snippy').expand_snippet(args.body)
				-- 		-- vim.fn["UltiSnips#Anon"](args.body)
				-- 	end,
				-- },
				sources = cmp.config.sources({
					{ name = "buffer" }, -- test one source at a time
				}),
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "lua" }, -- add here the languages for your test case
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	{
		"ggandor/flit.nvim",
		config = function()
			require("flit").setup({
				labeled_modes = "nv",
			})
		end,
		dependencies = { "leap.nvim" },
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter" } },
}, {
	root = vim.fn.stdpath("run") .. "/visual.nvim-test/plugins",
	sate = vim.fn.stdpath("run") .. "/visual.nvim-test/lazy.json",
})
