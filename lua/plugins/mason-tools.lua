return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    ensure_installed = {
      "stylua",   -- форматтер Lua
      -- rubocop СОЗНАТЕЛЬНО не ставим через mason. У нас asdf с кучей ruby под
      -- проекты — mason же поставил бы gem в ОДНУ (глобальную) ruby, и в проекте
      -- на другой версии его бы не было (плюс игнорировался бы .rubocop.yml
      -- проекта). Правильно — запускать rubocop из бандла проекта: `bundle exec
      -- rubocop`. Сейчас он и так нигде не вызывается (формат — rubyfmt в
      -- formatting.lua, линт Ruby — ruby-lsp), поэтому просто убран. Если решишь
      -- вернуть style-линт: в linting.lua добавь ruby = { "rubocop" } с
      -- линтером, настроенным на `bundle exec`.
      "shfmt",    -- форматтер Bash
      "prettier", -- форматтер JS/TS/etc
      "eslint_d", -- линтер JS/TS
      "ruff",     -- форматтер+линтер Python
    },
  },
}
