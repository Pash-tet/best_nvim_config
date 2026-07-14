return {
  "folke/snacks.nvim",
  -- lazy=false + высокий priority — как у LazyVim самого core-спека snacks.nvim
  -- (сверено по исходнику lazyvim/plugins/init.lua): Snacks — общая
  -- utility-библиотека (rename, notify и т.п.), на неё полагаются другие
  -- плагины (напр. neo-tree.lua дёргает Snacks.rename при переименовании
  -- файла в дереве) — она должна существовать к моменту, когда до неё
  -- дотянутся, а не только после первого нажатия своих собственных keys.
  lazy = false,
  priority = 1000,
  opts = {
    -- explorer убран — вернулись на neo-tree.nvim (см. lua/plugins/neo-tree.lua),
    -- у которого есть полноценный git_status-источник (LazyVim ставит его как
    -- opt-in extra именно за это). Snacks остаётся ради терминала + Snacks.rename.
    terminal = {
      win = {
        position = "bottom",
        height = 0.3,
      },
    },
  },
  keys = {
    -- Ctrl+/ шлётся терминалом по-разному: 0x1F=<C-_> в tmux/iTerm2/VSCode
    -- по умолчанию, <C-/> с kitty/CSI-u протоколом — вешаем оба на одно и
    -- то же (та же логика, что раньше в toggleterm.lua).
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
    {
      "<c-_>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
  },
}
