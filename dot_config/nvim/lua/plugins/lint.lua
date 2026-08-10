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
        oxlint = function(_, opts)
          opts.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
          return false
        end,
      },
    },
  },
}
