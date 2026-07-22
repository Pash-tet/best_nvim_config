return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  -- Раскладка буферов как в LazyVim: <S-h>/<S-l> и [b/]b — переключение,
  -- [B/]B — перемещение вкладки, группа <leader>b — управление буферами.
  keys = {
    { "<S-h>", "<cmd>bprevious<CR>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>bnext<CR>", desc = "Next buffer" },
    { "[b", "<cmd>bprevious<CR>", desc = "Prev buffer" },
    { "]b", "<cmd>bnext<CR>", desc = "Next buffer" },
    { "[B", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
    { "]B", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
    { "<leader>bb", "<cmd>e #<CR>", desc = "Switch to other buffer" },
    -- Snacks.bufdelete, а НЕ голый :bdelete: bdelete закрывает ещё и ОКНО
    -- буфера, если в tab'е есть другие окна. С открытым neo-tree это
    -- приводило к выходу из nvim целиком: окно файла закрывается, остаётся
    -- одно окно neo-tree, и его close_if_last_window делает q!.
    -- Snacks.bufdelete удаляет буфер, сохраняя раскладку окон.
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete buffer",
    },
    { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
    { "<leader>bj", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
  },
  opts = {
    options = {
      -- Крестик на вкладке и right-click по ней: по умолчанию тут
      -- "bdelete! %d", который закрывает и ОКНО буфера — при открытом
      -- neo-tree это выходило из nvim целиком (см. комментарий у <leader>bd
      -- выше: остаётся одно окно дерева, и close_if_last_window делает q!).
      -- Snacks.bufdelete закрывает буфер, не трогая окна.
      close_command = function(n)
        Snacks.bufdelete(n)
      end,
      right_mouse_command = function(n)
        Snacks.bufdelete(n)
      end,
      -- diagnostics из vim.diagnostic (тот же поток, что LSP+nvim-lint,
      -- см. core/diagnostics.lua) — счётчик ошибок прямо на вкладке буфера.
      diagnostics = "nvim_lsp",
      -- БЕЗ этого sidebar neo-tree будет ПЕРЕКРЫТ полосой вкладок сверху —
      -- offsets резервирует место над окном под подпись. filetype="neo-tree"
      -- сверено по исходнику neo-tree (ui/renderer.lua: vim.bo[bufnr].filetype
      -- = "neo-tree").
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
