return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },       -- готовые сниппеты для кучи языков
  version = "1.*",                                         -- фиксируем релизный тег -> качается ГОТОВЫЙ бинарник фаззи-мэтчера (Rust), компилятор не нужен
  opts = {
    keymap = { preset = "enter" },                         -- Enter подтверждает выделенный вариант, как в VSCode
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },  -- показывать документацию к пункту меню автоматически
      -- list.selection.preselect по умолчанию true — первый вариант подсвечен сразу,
      -- поэтому Enter подтверждает его немедленно, без стрелок (то, что ты и просил).
      -- Плата за это: если меню открыто и ты жмёшь Enter просто ради новой строки —
      -- вставится подсказка вместо неё. Это осознанный выбор в пользу VSCode-подобного поведения.
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },   -- откуда брать варианты автодополнения
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
