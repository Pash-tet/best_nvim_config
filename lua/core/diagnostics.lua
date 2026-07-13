-- Настройка ОТОБРАЖЕНИЯ диагностики.
-- "Диагностика" в Neovim — единый поток ошибок/предупреждений: сюда стекаются
-- и подчёркивания от LSP (ruby-lsp, lua_ls...), и находки nvim-lint (rubocop).
-- Поэтому ОДИН vim.diagnostic.config() управляет показом ОБОИХ источников сразу.

vim.diagnostic.config({
  -- virtual_lines + current_line=true — текст ошибки на отдельной строке ПОД
  -- курсором, но ТОЛЬКО для строки, где курсор сейчас. Экран не засоряется, а
  -- полное сообщение видно без наведения. Нативная фича Neovim 0.11+.
  virtual_lines = { current_line = true },

  -- virtual_text выключаем ЯВНО: иначе к virtual_lines добавился бы ещё и
  -- inline-текст справа от строки — то же сообщение задвоилось бы.
  virtual_text = false,

  -- подчёркивание оставляем — оно помечает ТОЧНОЕ место в строке (столбцы),
  -- чего строка-снизу не показывает.
  underline = true,

  -- значки слева в signcolumn (мы её зарезервировали в options.lua, signcolumn="yes").
  -- text — символы по уровням серьёзности: codepoints U+F057/F071/F05A/F0EB
  -- (Font Awesome набор внутри Nerd Font) — times-circle/exclamation-triangle/
  -- info-circle/lightbulb. Символы невидимы в редакторах без Nerd Font (это
  -- Private Use Area — без патченного шрифта показывает пустоту, а не "квадратик
  -- с вопросом", как обычные неизвестные символы). Если когда-нибудь сменишь
  -- терминальный шрифт на не-Nerd — замени text на буквы "E"/"W"/"I"/"H".
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },

  -- при НЕСКОЛЬКИХ диагностиках на одной строке — сортировать по серьёзности,
  -- чтобы значок и подсветка показывали САМУЮ важную (ERROR, а не HINT).
  severity_sort = true,

  -- настройки всплывающего окна (float). Его можно открыть вручную
  -- (vim.diagnostic.open_float), и оно же используется при паузе курсора.
  -- source=true — показывать, ОТКУДА пришла ошибка (ruby-lsp / rubocop): полезно,
  -- когда LSP и линтер ругаются на одно место. border — рамка для читаемости.
  float = {
    border = "rounded",
    source = true,
  },
})

-- Навигация по диагностике в стиле LazyVim: ]d/[d — любая, ]e/[e — только
-- ошибки, ]w/[w — только предупреждения. float=true всплывает сообщением при
-- прыжке (не нужно отдельно наводиться). ]d/[d есть и во встроенном nvim —
-- переопределяем ради этого float и единообразия с ]e/]w.
local function diag_jump(count, severity)
  return function()
    vim.diagnostic.jump({
      count = count,
      float = true,
      severity = severity and vim.diagnostic.severity[severity] or nil,
    })
  end
end

local map = vim.keymap.set
map("n", "]d", diag_jump(1), { desc = "Next diagnostic" })
map("n", "[d", diag_jump(-1), { desc = "Prev diagnostic" })
map("n", "]e", diag_jump(1, "ERROR"), { desc = "Next error" })
map("n", "[e", diag_jump(-1, "ERROR"), { desc = "Prev error" })
map("n", "]w", diag_jump(1, "WARN"), { desc = "Next warning" })
map("n", "[w", diag_jump(-1, "WARN"), { desc = "Prev warning" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
