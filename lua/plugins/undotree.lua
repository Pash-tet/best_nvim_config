return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  -- undofile (см. lua/core/options.lua) уже сохраняет историю undo на диск
  -- между запусками nvim — этот плагин просто даёт визуальное дерево поверх
  -- неё (ветки после отмены и переход по узлам), которые голый u/Ctrl-r не
  -- показывают.
  keys = {
    { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undotree Toggle" },
  },
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
}
