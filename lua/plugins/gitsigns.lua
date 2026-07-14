return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Раскладка по образцу LazyVim: ]h/[h — навигация по hunk'ам, ]H/[H — к
    -- последнему/первому, группа <leader>gh — действия над hunk'ом (h = hunk).
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Навигация. В режиме :diff (vim.wo.diff) отдаём управление нативным
      -- ]c/[c, иначе — прыжки gitsigns по hunk'ам.
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev hunk")
      map("n", "]H", function()
        gs.nav_hunk("last")
      end, "Last hunk")
      map("n", "[H", function()
        gs.nav_hunk("first")
      end, "First hunk")

      -- Действия над hunk'ом (<leader>gh...)
      map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>ghs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("v", "<leader>ghr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>ghb", function()
        gs.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>ghd", gs.diffthis, "Diff this")
      map("n", "<leader>ghD", function()
        gs.diffthis("~")
      end, "Diff this ~")

      -- Text object: ih — выделить hunk (для d/y/c ih и в visual-режиме)
      map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
    end,
  },
}
