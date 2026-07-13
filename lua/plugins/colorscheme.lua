-- Один файл в lua/plugins/ = один или несколько plugin spec'ов (return таблица/список таблиц).
-- lazy.nvim подхватит этот файл автоматически благодаря { import = "plugins" }
return {
  "folke/tokyonight.nvim",  -- "автор/репозиторий" на GitHub — так lazy.nvim понимает, что клонировать
  priority = 1000,          -- грузить ПЕРВЫМ (до других плагинов) — важно для цветовых схем
  config = function()
    -- config — функция, которая выполнится ПОСЛЕ того как плагин скачан и загружен
    vim.cmd.colorscheme("tokyonight")
  end,
}
