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
      -- eruby — это filetype, который nvim ставит *.erb/*.html.erb (не "erb").
      -- ft_parsers/ext_parsers не задаём: conform без них зовёт `prettier
      -- --stdin-filepath $FILENAME`, и парсер prettier выбирает САМ по имени
      -- файла через overrides в .prettierrc проекта (нужен erb-плагин типа
      -- @4az/prettier-plugin-html-erb + { files: "*.erb", parser:
      -- "erb-template" } — см. na_taganrog/.prettierrc). В проекте БЕЗ такого
      -- плагина/оверрайда prettier упадёт с ошибкой на *.erb — conform НЕ
      -- откатывается тихо на другой форматтер, format_on_save покажет notify
      -- с ошибкой prettier. Если работаешь с erb в проекте без этого плагина —
      -- либо поставь его туда, либо на время убери "eruby" отсюда.
      eruby = { "prettier" },
      sh = { "shfmt" },
      -- json — без отдельного CLI-форматтера: пустой список форматтеров +
      -- lsp_format = "fallback" переключает conform на уже запущенный jsonls
      -- (см. lua/plugins/lsp.lua). Быстрее внешнего процесса (prettier и т.п.),
      -- т.к. не спавнит новый процесс на каждое сохранение.
      json = { lsp_format = "fallback" },
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
      -- Catch-all ["_"] = {"trim_whitespace"} выше даёт форматтер КАЖДОМУ
      -- filetype без явной записи в formatters_by_ft, поэтому глобальный
      -- lsp_format здесь был бы мёртвым — "нет форматтера" не случается.
      -- Для json это обойдено точечно: formatters_by_ft.json = { lsp_format =
      -- "fallback" } (см. выше) — явная запись перебивает "_" и включает
      -- форматирование через jsonls. Если позже появится LSP с форматированием
      -- для html/css — та же точечная запись, а не глобальный lsp_format.
    },
  },
}
