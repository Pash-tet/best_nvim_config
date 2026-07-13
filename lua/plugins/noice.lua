return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim", -- строит floating/popup окна noice изнутри
    "rcarriga/nvim-notify", -- запасной backend для vim.notify(), если понадобится
  },
  opts = {
    -- ВАЖНО: noice САМ ПО СЕБЕ не двигает командную строку с нижней строки —
    -- он лишь ПЕРЕХВАТЫВАЕТ события cmdline/messages и рисует их floating-
    -- окнами. Нижняя строка (native cmdline, высота = vim.o.cmdheight) при
    -- этом остаётся зарезервированной пустой полосой ПОД lualine. Чтобы
    -- lualine реально стал последней строкой — схлопываем её:
    -- vim.o.cmdheight = 0 (задано в core/options.lua, рядом с остальными
    -- UI-опциями).

    routes = {
      -- Гасим "No information available" от vim.lsp.buf.hover(). Появляется в
      -- .erb при K на CSS-классе: hover опрашивает ВСЕ прицепленные LSP, и пока
      -- html-css отдаёт инфу по классу, ruby_lsp на том же слове возвращает
      -- пусто → Neovim шлёт это INFO-уведомление. Само окно hover (CSS-инфа) от
      -- этого не страдает — глушим только пустой notice. В .rb такого нет: там
      -- html-css не подключается, а ruby_lsp сам знает символ.
      -- ВНИМАНИЕ: подавляется ГЛОБАЛЬНО (и при K по символу без hover в любом
      -- файле). Это сообщение — почти всегда шум (реальный сигнал = окно hover),
      -- поэтому убираем везде.
      {
        filter = { find = "No information available" },
        opts = { skip = true },
      },
    },

    messages = {
      -- Диагностика ex-команд (как твой E486) идёт через messages.view_error,
      -- не через notify — это разные пути в noice. По умолчанию error/warn
      -- рисуются через nvim-notify (верхний правый угол). Переключаем на
      -- встроенный view "mini" — маленький, ненавязчивый, без внешней
      -- зависимости. Позиция — дефолтная НИЗ-ПРАВО (views.mini.position ниже
      -- не трогаем, она уже { row = -1, col = "100%" } "из коробки").
      view_error = "mini",
      view_warn = "mini",
    },

    -- cmdline (ввод команд/поиска) и confirm (диалог "Save changes?") НЕ
    -- трогаем — они УЖЕ отцентрованы по умолчанию: cmdline через view
    -- "cmdline_popup" (position row="50%", col="50%"), confirm — свой view
    -- с align="center" (position row=3, col="50%"). Проверено в исходнике
    -- noice/config/views.lua, до правки конфига.
  },
}
