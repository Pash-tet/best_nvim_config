-- vim.api.nvim_create_autocmd(event, opts)
--   event: имя события ("BufWritePre", "TextYankPost", ...) или список событий
--   opts.group:    "группа" автокоманд — см. пояснение про augroup ниже
--   opts.pattern:  на какие файлы реагировать ("*" — на все, "*.lua" — только lua и т.д.)
--   opts.callback: функция, которая выполнится (можно и opts.command — строка команды)

-- augroup — это просто "именованный контейнер" для автокоманд.
-- Главная причина существования: если конфиг перезагрузить (:source %),
-- без группы + clear=true автокоманда зарегистрируется ВТОРОЙ раз поверх первой,
-- и событие сработает дважды. clear=true говорит: "перед созданием — удали все
-- автокоманды, что раньше были в этой группе".
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 1) Подсветить на секунду то, что скопировали (yank) — чисто визуальная обратная связь
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    -- vim.hl (раньше vim.highlight) — модуль переименован в Neovim 0.11,
    -- старое имя оставлено как deprecated-обёртка и будет удалено.
    vim.hl.on_yank({ timeout = 200 })
  end,
  desc = "Highlight yanked text briefly",
})

-- 2) Вернуть курсор туда, где ты был в файле в прошлый раз, при повторном открытии
-- (обрезку висящих пробелов раньше делали здесь руками — теперь это часть
-- conform.nvim, catch-all "_" = {"trim_whitespace"} в lua/plugins/formatting.lua)
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')  -- '"' — mark последней позиции в буфере
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
  desc = "Restore cursor position on file reopen",
})

-- 3) Автосохранение "при потере фокуса" (как onFocusChange в VSCode). Сохраняем
-- ТОЛЬКО когда уходишь с файла/из nvim, а НЕ во время набора — иначе conform
-- (format_on_save) переформатировал бы код прямо посреди редактирования.
local function autosave(buf)
  -- Ранние return'ы: не пишем то, что писать нельзя/незачем.
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if not vim.bo[buf].modified then return end        -- нечего сохранять
  if vim.bo[buf].buftype ~= "" then return end        -- только обычные файловые буферы (не terminal/explorer/nofile)
  if not vim.bo[buf].modifiable then return end
  if vim.bo[buf].readonly then return end
  if vim.api.nvim_buf_get_name(buf) == "" then return end -- нет имени файла — writer'у некуда писать

  -- Пишем КОНКРЕТНЫЙ буфер (не полагаясь на "текущий" — надёжно в контексте
  -- BufLeave/FocusLost). "write" штатно триггерит format_on_save.
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)
end

autocmd({ "BufLeave", "FocusLost" }, {
  -- BufLeave — ушёл с буфера на другой; FocusLost — nvim потерял фокус
  -- (свернул/переключился на другое приложение), зависит от focus-reporting
  -- терминала (tmux/iTerm2/VSCode-терминал поддерживают).
  group = augroup("autosave", { clear = true }),
  callback = function()
    -- Проходим ПО ВСЕМ буферам — сохранится всё несохранённое, как в VSCode
    -- на blur, а не только текущий (autosave сам отсеет неподходящие).
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      autosave(buf)
    end
  end,
  desc = "Autosave modified file buffers on focus/buffer leave",
})
