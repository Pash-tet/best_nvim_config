return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- "VeryLazy" — синтетическое событие самого lazy.nvim,
  -- срабатывает сразу после старта, когда экран уже отрисован.
  opts = {
    -- helix-preset: компактный однострочный стиль (иконка → описание, "+group"
    -- для групп) — тот самый вид, что в LazyVim по умолчанию (editor.lua).
    preset = "helix",
    -- Подписи групп (LazyVim-стиль): когда нажмёшь <leader> и подождёшь,
    -- which-key покажет меню, где префиксы сгруппированы с человеческими
    -- названиями вместо голого списка. spec (which-key v3) принимает записи
    -- { "<prefix>", group = "имя" }.
    spec = {
      { "<leader>a", group = "Claude" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
      { "gs", group = "surround" },
    },

    -- Дефолтные icons.rules (which-key/icons.lua) расставляют иконки по
    -- угаданным словам в desc ("buffer", "toggle", "code"...). Для команд
    -- claudecode.nvim ("Focus Claude", "Accept diff" и т.п.) под эти слова
    -- почти ничего не попадает, поэтому иконка была бы только у части
    -- пунктов и то случайно. Явное plugin-правило (по образцу дефолтных
    -- CopilotChat.nvim/snacks.nvim в самом which-key) даёт ОДНУ одинаковую
    -- иконку сразу всей группе — и заголовку "<leader>a", и каждому
    -- подпункту, — независимо от формулировки desc.
    icons = {
      rules = {
        { plugin = "claudecode.nvim", icon = " ", color = "green" },
      },
    },
  },
}
