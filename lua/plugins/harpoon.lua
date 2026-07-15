return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2", -- новый API (list-based), НЕ старый harpoon1
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  -- Идея: 3-5 "закладок" на файлы, над которыми сейчас реально работаешь
  -- (контроллер+вьюха+модель и т.п.) — быстрее, чем telescope, когда файлы
  -- уже известны заранее, а не ищутся заново каждый раз.
  keys = function()
    local keys = {
      -- <leader>H: добавить ТЕКУЩИЙ файл в список закладок harpoon.
      {
        "<leader>H",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      -- <leader>h: открыть меню закладок (обычный буфер, можно редактировать
      -- список руками: удалить строку = убрать закладку, переставить строки
      -- местами = поменять порядок номеров).
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }

    -- <leader>1..5: мгновенный прыжок на закладку под этим номером.
    for i = 1, 5 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
}
