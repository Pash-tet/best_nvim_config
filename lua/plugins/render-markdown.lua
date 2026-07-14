-- render-markdown.nvim: рендер markdown ПРЯМО в буфере (заголовки, списки,
-- код-блоки, таблицы, чекбоксы, callout'ы) — как в Obsidian. На строке, где
-- стоит курсор, всегда показывается сырой markdown для редактирования
-- ("anti-conceal"), рендер работает только вне Insert-режима (без дёргания
-- при наборе). Сверено с README установленной версии (curl, не по памяти) —
-- предпочли markview.nvim за стабильность API и меньше зависимостей (у
-- markview README сам предупреждает, что релизные теги отстают от main).
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown", -- README: безопасно грузить лениво именно по filetype
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- парсеры markdown/markdown_inline уже стоят (treesitter.lua)
    "nvim-tree/nvim-web-devicons", -- уже используется в проекте (neo-tree/telescope/dashboard) — иконки языков в код-блоках
  },
  opts = {},
}
