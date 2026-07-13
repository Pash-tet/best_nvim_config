return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- "VeryLazy" — синтетическое событие самого lazy.nvim,
  -- срабатывает сразу после старта, когда экран уже отрисован.
  opts = {
    -- Подписи групп (LazyVim-стиль): когда нажмёшь <leader> и подождёшь,
    -- which-key покажет меню, где префиксы сгруппированы с человеческими
    -- названиями вместо голого списка. spec (which-key v3) принимает записи
    -- { "<prefix>", group = "имя" }.
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
    },
  },
}
