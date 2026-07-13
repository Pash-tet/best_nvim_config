return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope", -- лениво: грузится только по команде/маппингу ниже
  dependencies = {
    "nvim-lua/plenary.nvim", -- общая lua-утилита, на которой построен telescope
    {
      -- fzf-алгоритм сортировки/фильтрации, скомпилированный как C-модуль —
      -- на порядок быстрее встроенного lua-сортировщика на больших проектах.
      -- build="make" — компилируется ОДИН раз при установке плагина (нужен
      -- компилятор, у нас есть: make/gcc/clang уже в системе).
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  -- Раскладка по образцу LazyVim: группа "f" = file/find, группа "s" = search.
  keys = {
    -- <leader><leader> (у нас leader=пробел, т.е. это и есть LazyVim'овский
    -- <leader><space>) — аналог двойного Shift в RubyMine ("Search
    -- Everywhere"). Голый повторный Shift терминал в принципе не передаёт nvim.
    { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find files" },

    -- find (файлы/буферы)
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    {
      "<leader>fc",
      function()
        require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find config file",
    },
    -- <leader>fg — grep. В LazyVim grep живёт под <leader>sg / <leader>/, но
    -- кнопка "Live grep" нашего стартового экрана (theta) жёстко зашита на
    -- <leader>fg — поэтому держим и его, и LazyVim-биндинги ниже (все три на
    -- один и тот же live_grep, лишним не будет).
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },

    -- search (поиск по содержимому и служебные пикеры) — как в LazyVim
    { "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
    { "<leader>/", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
    { "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "Word under cursor", mode = { "n", "x" } },
    { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Help pages" },
    { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
    { "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>sr", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },

    -- ui: живой пикер тем — enable_preview применяет colorscheme СРАЗУ при
    -- наведении на пункт (не только по Enter), <Esc>/<C-c> откатывает на ту,
    -- что была активна до открытия пикера (штатное поведение самого telescope).
    {
      "<leader>uc",
      function()
        require("telescope.builtin").colorscheme({ enable_preview = true })
      end,
      desc = "Colorscheme (live preview)",
    },
  },
  config = function()
    require("telescope").setup({})
    -- extension грузится ПОСЛЕ setup — иначе find_files не узнает, что можно
    -- использовать быстрый fzf-сортировщик вместо дефолтного lua-варианта.
    require("telescope").load_extension("fzf")
  end,
}
