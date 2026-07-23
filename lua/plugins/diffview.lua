return {
  "sindrets/diffview.nvim",
  -- Трёхпанельный merge-tool «как в JetBrains»: при открытом конфликте показывает
  -- OURS | РЕЗУЛЬТАТ | THEIRS тремя вертикальными панелями (diff3_horizontal —
  -- самый близкий к раскладке IDEA layout). Внутри merge-буфера работают:
  --   <leader>co — принять НАШУ версию (ours)      <leader>ct — принять ИХ (theirs)
  --   <leader>cb — базовую (base)                  <leader>ca — все три
  --   dx         — удалить конфликт целиком
  --   ]x / [x    — прыжки между конфликтами
  -- (это встроенные view-раскладки diffview, они buffer-local и не трогают
  -- глобальный <leader>c = "code").
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
  },
  keys = {
    -- Все точки входа сделаны тогглами: одна и та же клавиша открывает view, а
    -- если diffview уже открыт (в любом режиме) — закрывает его. Так не нужно
    -- помнить :DiffviewClose. Diffview живёт в отдельной вкладке, поэтому :q
    -- закрыл бы только панель — тоггл зовёт именно DiffviewClose.
    {
      "<leader>gd",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Diffview (тоггл)",
    },
    {
      "<leader>gm",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Merge-конфликты (тоггл)",
    },
    {
      "<leader>gf",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewFileHistory %")
        end
      end,
      desc = "История файла (тоггл)",
    },
    {
      "<leader>gF",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewFileHistory")
        end
      end,
      desc = "История репозитория (тоггл)",
    },
  },
  opts = {
    -- Раскладка панелей при разрешении конфликта.
    view = {
      merge_tool = {
        -- OURS | РЕЗУЛЬТАТ | THEIRS в три колонки — как в JetBrains.
        layout = "diff3_horizontal",
        disable_diagnostics = true,
      },
    },
  },
}
