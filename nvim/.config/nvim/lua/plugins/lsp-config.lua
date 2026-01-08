return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Lua
      vim.lsp.config.lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      }

      -- TypeScript / JavaScript (nouveau nom)
      vim.lsp.config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        root_markers = { "package.json", "tsconfig.json", ".git" },
      }

      -- Activer les serveurs
      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
      })
    end,
  },
}
