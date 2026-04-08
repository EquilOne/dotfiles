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

        -- Prettier
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier", "markdownlint-cli2", "injected", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "injected", "markdown-toc" },
        -- "injected" formats code blocks in markdown files
        yaml = { "prettier" },

        -- Config languages
        lua = { "stylua" },
        toml = { "tombi" },
        sh = { "shfmt" },
      },
      -- Customize specific formatters below:
      formatters = {
        -- Force 2 spaces for tabs in Prettier
        prettier = {
          prepend_args = { "--tab-width", "2" },
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
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
    },
  },
  -- Ensure tools installed via Mason
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Python
        "ruff",
        "pyright",
        -- Go
        "gofumpt",
        "goimports",
        -- Web
        "biome",
        "prettier",
        "vtsls",
        "css-lsp",
        "html-lsp",
        "tailwindcss-language-server",
        -- Lua
        "stylua",
        "lua-language-server",
        -- Shell
        "shfmt",
        "shellcheck",
        "bash-language-server",
        -- Config
        "tombi",
        "yaml-language-server",
        "yamllint",
        -- Markdown
        "markdownlint-cli2",
        "markdown-toc",
        "marksman",
        -- Docker
        "hadolint",
        -- Misc
        "codespell",
        -- Hyprland
        "hyprls",
      },
    },
  },
}
