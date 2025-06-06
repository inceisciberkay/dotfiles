return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	lazy = false,
	keys = {
		{
			"<F3>",
			function()
				require("conform").format({ async = false }, function(err)
					if not err then
						local mode = vim.api.nvim_get_mode().mode
						if vim.startswith(string.lower(mode), "v") then
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
						end
					end
				end)
			end,
			mode = { "n", "v", "i" },
			desc = "Format buffer",
		},
	},
	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { "stylua" },
			c = { lsp_format = "fallback" },
			rust = { "rustfmt" },
			python = { "isort", "black" },
			json = { "prettierd", "prettier", stop_after_first = true },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			sh = { "shfmt" },
			markdown = { "injected" },
		},
		-- Set default options
		-- default_format_opts = {
		-- 	lsp_format = "fallback",
		-- },
		-- Set up format-on-save
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, sh = true, bash = true, python = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			end
			return { timeout_ms = 1000 }
		end,

		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
