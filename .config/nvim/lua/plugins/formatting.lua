return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format", "black" },
          javascript = { "oxfmt" },
          typescript = { "oxfmt" },
          json = { "prettier" },
        },
      })
    end,
  },
}
