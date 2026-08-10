return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- Python: Ruff for formatting; import sorting
				python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },

				-- Go: Standard strict formatting + imports
				go = { "goimports", "gofumpt" },

				-- Web: Try Biome first, fallback to Prettier
				javascript = { "biome", "prettier", stop_after_first = true },
				typescript = { "biome", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettier", stop_after_first = true },
				json = { "biome", "prettier", stop_after_first = true },
				jsonc = { "biome", "prettier", stop_after_first = true },

				-- Prettier
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				markdown = { "prettier", "markdownlint-cli2", "injected", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "injected", "markdown-toc" },
				-- "injected" formats code blocks in markdown files
				yaml = { "prettier" },
				-- chezmoi templates: mask {{ }} template spans, then format as the target type
				gotmpl = { "chezmoi" },
				chezmoitmpl = { "chezmoi" },

				-- Config languages
				lua = { "stylua" },
				toml = { "tombi" },
				sh = { "shfmt" },
			},
			-- Customize specific formatters below:
			formatters = {
				biome = {
					condition = function(_, ctx)
						return #vim.fs.find({
							".prettierrc",
							".prettierrc.json",
							".prettierrc.jsonc",
							".prettierrc.yaml",
							".prettierrc.yml",
							".prettierrc.js",
							".prettierrc.cjs",
							".prettierrc.mjs",
							".prettierrc.toml",
							"prettier.config.js",
							"prettier.config.cjs",
							"prettier.config.mjs",
							"prettier.config.ts",
						}, { upward = true, path = ctx.dir }) == 0
					end,
				},
				-- Force 2 spaces for tabs in Prettier
				prettier = {
					prepend_args = { "--config-precedence", "prefer-file" },
					cwd = require("conform.util").root_file({
						".prettierrc",
						".prettierrc.json",
						".prettierrc.jsonc",
						".prettierrc.yml",
						"package.json",
					}),
				},
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					prepend_args = { "--config", vim.fn.expand("~/.markdownlint-cli2.jsonc") },
				},
			},
		},
	},
	-- Ensure tools installed via Mason
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				-- Web
				"biome",
				"prettier",
				"css-lsp",
				"html-lsp",
				-- Config
				"tombi",
				"yamllint",
				-- Docker
				"hadolint",
				-- Misc
				"codespell",
				"lazygit",
				"oxlint",
				-- Hyprland
				"hyprls",
			},
		},
	},
}
