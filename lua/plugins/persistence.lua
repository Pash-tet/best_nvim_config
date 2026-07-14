return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  init = function()
    -- Перед сохранением сессии закрываем neo-tree И вычищаем его буферы.
    -- Иначе mksession сохранит их, а при restore они восстанавливаются
    -- битыми (buftype=nofile не переживает десериализацию).
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        -- Закрыть окно neo-tree (сработает только если открыто)
        pcall(vim.cmd, "Neotree close")
        -- Вытереть neo-tree буферы из памяти — filetype "neo-tree"
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == "neo-tree" then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
        -- Если nvim был открыт как `nvim .`, arglist содержит "." — mksession
        -- ВСЕГДА сериализует arglist (это не завязано на neo-tree буферы выше),
        -- и при restore `$argadd .` пересоздаёт буфер на саму директорию. Хук
        -- neo_tree_start_directory в neo-tree.lua ловит такой буфер только на
        -- ПЕРВОМ запуске (once + argv(0)), а не при восстановлении сессии —
        -- поэтому этот directory-буфер никто не хватает, и в него залезает
        -- голый netrw. Чистим arglist перед сохранением, чтобы "." туда не попадал.
        pcall(vim.cmd, "%argdelete")
      end,
    })
  end,
  -- stylua: ignore
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
