return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "b0o/nvim-tree-preview.lua",
	config = function()
		-- disable netrw at the very start of your init.lua (strongly advised)
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- set termguicolors to enable highlight groups
		vim.opt.termguicolors = true

		require("nvim-tree").setup({
			sort_by = "case_sensitive",
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = false,
			},
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local lib = require("nvim-tree.lib")

				-- Important: When you supply an `on_attach` function, nvim-tree won't
				-- automatically set up the default keymaps. To set up the default keymaps,
				-- call the `default_on_attach` function. See `:help nvim-tree-quickstart-custom-mappings`.
				api.config.mappings.default_on_attach(bufnr)

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- grug-far
				local grug_far_replace = function()
					local node = lib.get_node_at_cursor()
					if node then
						local prefills = {
							-- get the current path and get the parent directory if a file is selected
							paths = node.type == "directory" and node.absolute_path
								or vim.fn.fnamemodify(node.absolute_path, ":h"),
						}

						local grug_far = require("grug-far")
						-- instance check
						if not grug_far.has_instance("explorer") then
							grug_far.open({
								instanceName = "explorer",
								prefills = prefills,
								staticTitle = "Find and Replace from Explorer",
							})
						else
							grug_far.open_instance("explorer")
							-- updating the prefills without clearing the search and other fields
							grug_far.update_instance_prefills("explorer", prefills, false)
						end
					end
				end

				vim.keymap.set("n", "S", grug_far_replace, opts("Search in directory"))

				-- nvim-tree-preview
				local preview = require("nvim-tree-preview")

				vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
				vim.keymap.set("n", "<Esc>", preview.unwatch, opts("Close Preview/Unwatch"))

				-- Option A: Smart tab behavior: Only preview files, expand/collapse directories (recommended)
				vim.keymap.set("n", "<Tab>", function()
					local ok, node = pcall(api.tree.get_node_under_cursor)
					if ok and node then
						if node.type == "directory" then
							api.node.open.edit()
						else
							preview.node(node, { toggle_focus = true })
						end
					end
				end, opts("Preview"))

				-- Option B: Simple tab behavior: Always preview
				-- vim.keymap.set('n', '<Tab>', preview.node_under_cursor, opts 'Preview')
			end,
		})

		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
	end,
}
