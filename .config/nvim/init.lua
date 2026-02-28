vim.env.PATH = "/usr/bin:/opt/homebrew/bin:" .. vim.env.PATH

require("core.options")
require("core.keymaps")
require("lazy_bootstrap")
require("core.lsp")

vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/nvim/bin/python")

