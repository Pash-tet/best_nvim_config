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
    -- :bdelete закрывает буфер; на ПОСЛЕДНЕМ буфере это закроет и окно (в
    -- LazyVim этим занимается Snacks.bufdelete, который сохраняет окно — у нас
    -- Snacks нет, поэтому простой :bdelete, поведение чуть отличается на краю).
    { "<leader>bd", "<cmd>bdelete<CR>", desc = "Delete buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
    { "<leader>bj", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
  },
  opts = {
    options = {
      -- diagnostics из vim.diagnostic (тот же поток, что LSP+nvim-lint,
      -- см. core/diagnostics.lua) — счётчик ошибок прямо на вкладке буфера.
      diagnostics = "nvim_lsp",
      -- БЕЗ этого sidebar snacks.explorer будет ПЕРЕКРЫТ полосой вкладок
      -- сверху — offsets резервирует место над окном под подпись.
      -- ВАЖНО: filetype="snacks_layout_box", НЕ "snacks_picker_list"/
      -- "snacks_picker_input". Проверено живьём через `vim.fn.winlayout()`:
      -- sidebar пикера — это ОДНО настоящее split-окно-контейнер
      -- ("snacks_layout_box", см. snacks/layout.lua) в дереве сплитов;
      -- input/list/preview ВНУТРИ него — floating-окна (не участвуют в
      -- winlayout вообще), поэтому offset.lua (исходник bufferline,
      -- работает только с реальными split-окнами) должен матчиться именно
      -- на контейнер, а не на то, что внутри него плавает.
      offsets = {
        {
          filetype = "snacks_layout_box",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
