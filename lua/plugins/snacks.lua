return {
  "folke/snacks.nvim",
  -- lazy=false + высокий priority (НЕ по умолчанию): explorer вешает перехват
  -- netrw через автокоманду BufEnter ВНУТРИ своего require("snacks").setup()
  -- (см. snacks/explorer/init.lua) — сработать это должно ДО того, как
  -- `nvim .` покажет голый netrw. При ленивой загрузке (по keys/cmd) плагин
  -- физически require()'ится только по первому нажатию — та же самая грабля,
  -- что раньше решали для neo-tree через init-хук (см. progress.md), только
  -- здесь штатное решение авторов плагина — грузить сразу.
  lazy = false,
  priority = 1000,
  opts = {
    -- Файловый sidebar вместо neo-tree. explorer — это picker (snacks
    -- picker) в "переодетом" виде; дефолтный layout уже preset="sidebar"
    -- (слева, ширина 40) — ровно то же место и вид, что был у neo-tree,
    -- отдельно ничего не задаём.
    explorer = {},
    picker = {},
    -- Терминал вместо toggleterm. win.position="bottom" — сплит снизу (как
    -- и раньше), height=0.3 — те же ~30% высоты экрана, что были в
    -- toggleterm.lua (там считалось через vim.o.lines * 0.3).
    terminal = {
      win = {
        position = "bottom",
        height = 0.3,
      },
    },
  },
  keys = {
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle file explorer" },
    -- Ctrl+/ шлётся терминалом по-разному: 0x1F=<C-_> в tmux/iTerm2/VSCode
    -- по умолчанию, <C-/> с kitty/CSI-u протоколом — вешаем оба на одно и
    -- то же (та же логика, что раньше в toggleterm.lua).
    {
      "<c-/>",
      function() Snacks.terminal() end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
    {
      "<c-_>",
      function() Snacks.terminal() end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
  },
}
