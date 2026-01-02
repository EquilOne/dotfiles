return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Python: Ruff for formatting; import sorting
        python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },

        -- Go: Standard strict formatting + imports
        go = { "goimports", "ogfumpt" },

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
        markdown = { "prettier", "injected" },
        -- "injected" formats code blocks in markdown files
        yaml = { "prettier" },

        -- Config languages
        lua = { "stylua" },
        toml = { "taplo" },
        sh = { "shfmt" },
      },
      -- Customize specific formatters below:
      formatters = {
        -- Force 2 spaces for tabs in Prettier
        prettier = {
          prepend_args = { "--tab-width", "2" },
        },
      },
    },
  },

  -- Ensure tools installed via Mason
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff", -- Python
        "gofumpt", -- Go
        "goimports", -- Go
        "biome", -- Web
        "prettier", -- Web/Markdown
        "stylua", -- Lua
        "taplo", -- TOML
        "shfmt", -- Shell
      },
    },
  },
}
