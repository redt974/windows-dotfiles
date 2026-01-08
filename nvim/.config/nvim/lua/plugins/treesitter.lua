return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = "npm install -g tree-sitter-cli && :TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "typescript",
          "json",
          "yaml",
          "html",
          "css",
          "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
