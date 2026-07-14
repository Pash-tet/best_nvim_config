-- mini.surround: быстро добавлять/менять/удалять обёртки (кавычки, скобки,
-- теги) вокруг текстового объекта. Конфиг и кеймапы (gs-префикс) взяты из
-- реального extras/coding/mini-surround.lua LazyVim (curl с
-- raw.githubusercontent.com, не по памяти), но без хелпера LazyVim.opts()
-- (его у нас нет) — mappings продублированы напрямую в keys.
return {
  "nvim-mini/mini.surround",
  keys = {
    { "gsa", desc = "Add Surrounding", mode = { "n", "x" } },
    { "gsd", desc = "Delete Surrounding" },
    { "gsf", desc = "Find Right Surrounding" },
    { "gsF", desc = "Find Left Surrounding" },
    { "gsh", desc = "Highlight Surrounding" },
    { "gsr", desc = "Replace Surrounding" },
    { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
  },
  opts = {
    mappings = {
      add = "gsa", -- добавить обёртку (Normal и Visual)
      delete = "gsd", -- удалить обёртку
      find = "gsf", -- найти обёртку справа от курсора
      find_left = "gsF", -- найти обёртку слева от курсора
      highlight = "gsh", -- подсветить обёртку
      replace = "gsr", -- заменить обёртку
      update_n_lines = "gsn", -- обновить n_lines (радиус поиска обёртки)
    },
  },
}
