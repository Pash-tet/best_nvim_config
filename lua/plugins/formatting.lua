return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- нужен как раз перед сохранением
  cmd = "ConformInfo",
  -- <leader>cf — ручное форматирование (в дополнение к format_on_save), как в
  -- LazyVim. Работает и на выделении (visual-режим форматирует только диапазон).
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- rubyfmt — форматтер (быстрый Rust-бинарник). Стоит через brew
      -- (/opt/homebrew/bin/rubyfmt), НЕ через mason — поэтому его нет в
      -- mason-tools.lua; conform находит его на PATH. rubocop при этом остаётся
      -- ЛИНТЕРОМ в linting.lua (форматирование и линтинг Ruby теперь разными
      -- инструментами: rubyfmt раскладывает код, rubocop проверяет стиль/правила).
      ruby = { "rubyfmt" },
      python = { "ruff_format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      sh = { "shfmt" },
      -- "_" — catch-all для файлов без своего форматтера в списке выше
      ["_"] = { "trim_whitespace" },
    },
    format_on_save = {
      -- timeout_ms — потолок на СИНХРОННОЕ форматирование при сохранении (блокирует
      -- запись, если формат не успел). Это именно ceiling, а не задержка: если
      -- форматтер быстрый — таймаут не трогается. rubyfmt (Rust) быстрый; самый
      -- медленный из наших теперь prettier (холодный старт node), поэтому берём
      -- с запасом. Раньше запас был из-за rubocop, но он больше не форматтер.
      timeout_ms = 3000,
      -- ВНИМАНИЕ про lsp_format: conform запускает LSP-форматтер как фолбэк
      -- ТОЛЬКО когда для буфера не нашлось НИ ОДНОГО conform-форматтера.
      -- Но catch-all ["_"] = {"trim_whitespace"} выше даёт форматтер КАЖДОМУ
      -- filetype, поэтому "нет форматтера" не случается никогда — lsp_format
      -- был бы мёртвым. Сознательно выбираем: всегда обрезать хвостовые пробелы
      -- (реальная польза для всех файлов) вместо LSP-фолбэка (сейчас ни один из
      -- наших filetype'ов без CLI-форматтера не имеет LSP, умеющего форматировать).
      -- Если позже добавишь json/html/css LSP — убери "_" и верни
      -- lsp_format = "fallback", тогда фолбэк оживёт.
    },
  },
}
