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
    -- telescope-undo — курсор по списку истории undo двигает ТОЛЬКО live-diff
    -- в превью-окне; восстановление состояния — <C-r> (insert) / u (normal).
    -- Enter — это НЕ restore, а yank_additions (дефолты плагина).
    -- ВАЖНО: при ОТКРЫТИИ пикера плагин синхронно прогоняет буфер через все
    -- undo-состояния (строит диффы через `silent undo N`) и возвращает назад.
    -- Этот шторм didChange-пачек ловит гонку в ruby-lsp: сервер парсит документ
    -- в момент ПРИХОДА pull-diagnostic-запроса (reader-поток), а обрабатывает
    -- очередь позже (worker) — если между ними в очереди стоял didChange,
    -- диагностика считается по устаревшему parse_result и КЕШИРУЕТСЯ для нового
    -- документа. Симптом: после отката через undo-пикер висят фантомные ошибки
    -- (или наоборот — реальные не показываются), пока не начнёшь печатать.
    -- Обход — resync в нашем <leader>su ниже.
    "debugloop/telescope-undo.nvim",
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
    -- <leader>su — не голый <cmd>Telescope undo<CR>: оборачиваем, чтобы после
    -- закрытия пикера пересинхронизировать документ с LSP-серверами, у которых
    -- pull-диагностика (см. комментарий у telescope-undo в dependencies выше —
    -- иначе ruby-lsp остаётся с протухшим кешем диагностики до следующей правки).
    -- detach+attach = didClose+didOpen с полным текстом: сервер пересоздаёт
    -- документ с нуля, а nvim по didOpen сам перезапрашивает диагностику.
    {
      "<leader>su",
      function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd("Telescope undo")
        local prompt = vim.api.nvim_get_current_buf()
        if vim.bo[prompt].filetype ~= "TelescopePrompt" then
          return
        end
        vim.api.nvim_create_autocmd("BufWipeout", {
          buffer = prompt,
          once = true,
          callback = function()
            -- отложенно: даём changetracking'у дослать накопленные didChange
            -- (debounce 150ms), и только потом сбрасываем состояние сервера
            vim.defer_fn(function()
              if not vim.api.nvim_buf_is_valid(buf) then
                return
              end
              for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
                if client:supports_method("textDocument/diagnostic") then
                  vim.lsp.buf_detach_client(buf, client.id)
                  vim.lsp.buf_attach_client(buf, client.id)
                end
              end
            end, 300)
          end,
        })
      end,
      desc = "Undo history (preview)",
    },

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
    require("telescope").load_extension("undo")
  end,
}
