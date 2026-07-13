return {
  -- dir вместо "автор/репозиторий" -> lazy.nvim подключает ЛОКАЛЬНУЮ папку как есть,
  -- НИКОГДА не трогает её git-командами (не перезатрёт наш патч при :Lazy sync/update)
  dir = vim.fn.stdpath("config") .. "/vendor/nvim-treesitter-endwise",
  name = "nvim-treesitter-endwise", -- у dir-плагинов нет "автор/репо", имя задаём явно
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false, -- как и treesitter — грузим сразу, сам плагин решает, когда реагировать
}
