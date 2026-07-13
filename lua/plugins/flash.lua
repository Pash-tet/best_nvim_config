return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    -- s: печатаешь 1-2 символа -> на ВСЕХ совпадениях в видимой области экрана
    -- появляются лейблы-буквы -> жмёшь лейбл -> курсор телепортируется туда.
    -- ЗАМЕЧАНИЕ: перекрывает нативные vim-команды "s" (substitute char, = cl)
    -- и "S" (substitute line, = cc) — общепринятый trade-off у flash.nvim,
    -- т.к. cl/cc делают ровно то же самое другими клавишами.
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    -- S: то же самое, но лейблы ставятся на treesitter-узлах (функции,
    -- блоки и т.д.) — быстрый прыжок по структуре кода, а не по тексту.
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    -- r/R/<c-s> — как в LazyVim. r работает ТОЛЬКО в operator-pending режиме
    -- (после d/y/c) — там нативный "r" (replace char) не нужен, а вот в normal
    -- он остаётся собой. R — поиск по treesitter-структуре. <c-s> в командной
    -- строке (во время / поиска) переключает flash-подсветку.
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash search" },
  },
}
