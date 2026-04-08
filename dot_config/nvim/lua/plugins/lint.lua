return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          -- Points to your global rule config (Chezmoi-managed)
          args = { "--config", vim.fn.expand("~/.markdownlint-cli2.jsonc"), "--" },
        },
      },
    },
  },
}
