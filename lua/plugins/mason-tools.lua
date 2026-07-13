return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    ensure_installed = {
      "stylua",   -- форматтер Lua
      "rubocop",  -- форматтер+линтер Ruby
      "shfmt",    -- форматтер Bash
      "prettier", -- форматтер JS/TS/etc
      "eslint_d", -- линтер JS/TS
      "ruff",     -- форматтер+линтер Python
    },
  },
}
