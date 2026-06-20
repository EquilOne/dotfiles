return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        oxlint = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
      },
      setup = {
        biome = function(_, opts)
          opts.root_dir = require("lspconfig.util").root_pattern("biome.json")
          return false
        end,
        oxlint = function(_, opts)
          opts.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
          return false
        end,
      },
    },
  },
}
