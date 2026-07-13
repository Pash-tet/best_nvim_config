-- vim.keymap.set(mode, lhs, rhs, opts)
--   mode: строка или таблица строк — режим(ы), в которых работает биндинг
--         "n" normal, "i" insert, "v" visual, "x" visual (без select), "t" terminal
--   lhs:  что нажимаем ("<leader>w", "<C-h>", "jj" и т.д.)
--   rhs:  что происходит — строка-команда ИЛИ функция (см. урок про функции!)
--   opts: таблица настроек, самое важное — desc (описание, покажет which-key)

local map = vim.keymap.set

-- 1) Сохранение и выход — ДОСЛОВНО как в LazyVim.
--
-- Сохранение: <C-s> в insert/normal/visual/select. rhs "<cmd>w<cr><esc>" —
-- сохранить и вернуться в normal (<esc> нужен, если жал из insert). Это
-- основной сейв LazyVim (у них НЕ <leader>w).
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Выход из ПРОГРАММЫ: <leader>qq -> :qa (закрыть ВСЕ окна и выйти). Именно
-- qa, а не quit: quit закрывает лишь текущее окно, поэтому при открытом
-- neo-tree раньше <leader>q не завершал программу. В LazyVim это тоже <leader>qq.
-- ВНИМАНИЕ (поведение LazyVim): при несохранённых изменениях :qa откажется
-- выходить с E37 — сначала сохрани (<C-s>) или выйди без сохранения через :qa!.
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- 3) Режим "x" (visual, БЕЗ Select) — работает только когда есть выделение.
-- Именно "x", а не "v": "v" включает ещё и Select-режим, где печатаемая
-- клавиша должна ЗАМЕНЯТЬ выделение — вешать туда команду J/K неправильно
-- (см. шапку файла). Ниже маппинги <C-_> уже сделаны через "x" — тут так же.
-- Переместить выделенные строки вниз/вверх, сохраняя отступы
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- 4) Снять подсветку последнего поиска (после /слово)
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight", silent = true })
--                                     silent = true — не показывать саму команду внизу экрана

-- 6) Комментирование — используем ВСТРОЕННЫЕ gcc (строка) / gc (выделение)
-- из Neovim 0.10+ (модуль vim._comment, без плагина, treesitter-aware). Раньше
-- тут были кастомные хоткеи <C-/>/<C-_>/<D-/> на них — убрали по просьбе
-- пользователя (родных gcc/gc достаточно), а клавишу <C-/> отдали терминалу
-- (см. lua/plugins/snacks.lua).

-- 7) Быстрая навигация между окнами (splits) без зажатия <C-w> дважды
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to window above" })

-- 8) То же самое, но из terminal-mode (например, из окна claudecode.nvim).
-- В terminal-mode нажатия по умолчанию уходят напрямую в запущенный процесс
-- (в самого Claude), а не перехватываются маппингами Neovim — маппинги выше
-- заданы только для "n" (normal-mode). "<C-\\><C-n>" выходит из terminal-mode
-- в normal-mode ВНУТРИ терминального окна, дальше уже обычный <C-w>h/j/k/l.
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to window below" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to window above" })
