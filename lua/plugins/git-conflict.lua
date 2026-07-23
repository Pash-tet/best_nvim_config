return {
  "akinsho/git-conflict.nvim",
  version = "*",
  -- Inline-разрешение конфликтов прямо в открытом файле — как gutter-подсказки
  -- «Accept Yours / Accept Theirs» в JetBrains. Плагин подсвечивает блоки
  -- <<<<<<< / ======= / >>>>>>> цветами и вешает buffer-local хоткеи (активны
  -- ТОЛЬКО пока в буфере есть маркеры конфликта):
  --   co — принять НАШУ версию (current/ours)
  --   ct — принять ИХ (incoming/theirs)
  --   cb — обе (both)
  --   c0 — ни одной (none)
  --   ]x / [x — прыжки между конфликтами
  -- Событие :GitConflictDetected/Resolved даёт понять, что файл конфликтный.
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    default_mappings = true, -- co / ct / cb / c0 + ]x / [x
    default_commands = true, -- :GitConflict* команды
    disable_diagnostics = false,
    -- Открывать список всех конфликтов в quickfix через :GitConflictListQf.
    list_opener = "copen",
    highlights = {
      incoming = "DiffAdd",
      current = "DiffText",
    },
  },
}
