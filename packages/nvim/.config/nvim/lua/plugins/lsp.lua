return {
  -- LSP core
  {
    "neovim/nvim-lspconfig",
  },

  -- LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "tsserver",
          "pyright",
          "lua_ls",
        },
      })
    end,
  },

  -- Completion capabilities for LSP
  {
    "hrsh7th/cmp-nvim-lsp",
  },
}

