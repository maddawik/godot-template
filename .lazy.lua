vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("godot_lsp", { clear = true }),
	pattern = { "gd", "gdscript" },
	callback = function()
		local cmd = vim.lsp.rpc.connect("127.0.0.1", 6005)

		vim.lsp.start({
			name = "gdscript",
			filetypes = { "gdscript" },
			cmd = cmd,
			autostart = true,
			root_dir = vim.fs.dirname(vim.fs.find({ "project.godot", ".git" }, { upward = true })[1]),
		})
	end,
	desc = "Enable godot LSP for gdscript files",
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"gdscript",
			})
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"gdtoolkit",
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				gdscript = { "gdlint" },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				gdscript = { "gdformat" },
			},
			formatters = {
				gdformat = {
					prepend_args = { "--line-length", "120" },
				},
			},
		},
	},
	{
		"habamax/vim-godot",
		ft = { "gdscript", "gsl" },
	},
}
