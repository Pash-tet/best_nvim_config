-- ERB endwise: авто-вставка "<% end %>" при Enter после ERB-блока-открывашки.
--
-- ПОЧЕМУ СВОЁ, а не плагин: готового решения нет. nvim-treesitter-endwise к
-- eruby не подключается (is_supported("embedded_template")=false: в его
-- injection-запросе язык ruby задан директивой #set!, а не capture'ом, поэтому
-- проверка "есть ли вложенный язык с endwise" его не находит). А даже если
-- заставить подключиться — он вставил бы голый "end", т.к. внутри <% %>
-- treesitter видит только код ("items.each do"), без обёртки тега. tpope/
-- vim-endwise eruby тоже не знает. Отсюда — свой regex-обработчик.
--
-- КАК ХУКАЕМ: НЕ перехватываем <CR> маппингом (это перебило бы blink.cmp
-- preset="enter" и <CR>-правила autopairs). Вместо этого НАБЛЮДАЕМ за клавишей
-- через vim.on_key и дорабатываем строку уже ПОСЛЕ того, как перевод строки
-- вставлен — ровно так же устроен сам nvim-treesitter-endwise.

-- Ключевые слова, открывающие блок в начале ERB-тега (<% if ... %> и т.п.).
-- elsif/else/when СЮДА НЕ входят — они внутри уже открытого блока, свой end им
-- не нужен.
local BLOCK_KEYWORDS = {
  ["if"] = true,
  ["unless"] = true,
  ["while"] = true,
  ["until"] = true,
  ["for"] = true,
  ["case"] = true,
  ["begin"] = true,
}

-- Открывает ли ERB-код на строке блок (нужен ли "<% end %>")?
local function line_opens_erb_block(line)
  -- Вытащить код из ПОСЛЕДНЕГО <% ... %> на строке (учитываем <%=, <%-, -%>).
  -- В Lua-паттернах "%" экранируется как "%%", поэтому "<%" -> "<%%", "%>" -> "%%>".
  local code = line:match("<%%%-?=?(.-)%-?%%>%s*$")
  if not code then
    return false
  end
  code = vim.trim(code)

  -- 1) do-блок: код заканчивается на "do" (возможно с аргументами блока "do |x|").
  --    Сначала срезаем хвостовые "|args|", потом проверяем "do" как отдельное
  --    слово (%f[%w] — граница слова, чтобы "redo"/"todo" не считались за "do").
  local without_args = vim.trim((code:gsub("|[^|]*|%s*$", "")))
  if without_args:match("%f[%w]do$") then
    return true
  end

  -- 2) Ключевое слово в НАЧАЛЕ кода. Именно в начале — так постфиксные формы
  --    ("<%= link_to x if admin? %>") не считаются за блок: там первое слово
  --    "link_to", а не "if".
  local first_word = code:match("^(%a+)")
  if first_word and BLOCK_KEYWORDS[first_word] then
    return true
  end

  return false
end

-- Одна табуляция отступа с учётом expandtab/shiftwidth.
local function one_shift()
  if vim.bo.expandtab then
    return string.rep(" ", vim.fn.shiftwidth())
  end
  return "\t"
end

local function maybe_insert_erb_end()
  local crow = vim.api.nvim_win_get_cursor(0)[1]

  -- Реагируем ТОЛЬКО когда Enter создал свежую пустую строку. Если строка под
  -- курсором непустая — значит Enter, например, подтвердил автодополнение
  -- (blink), а не перенёс строку: тогда endwise не нужен.
  if vim.trim(vim.fn.getline(crow)) ~= "" then
    return
  end

  local opener = vim.fn.getline(crow - 1)
  if not line_opens_erb_block(opener) then
    return
  end

  -- Защита от дубля: если ниже уже стоит "<% end %>" (например, его вставил
  -- сниппет each/if из friendly-snippets) — второй не добавляем.
  if vim.fn.getline(crow + 1):match("^%s*<%%%-?%s*end%s*%-?%%>") then
    return
  end

  local indent = opener:match("^%s*") or ""
  -- Текущую пустую строку — на один уровень глубже (курсор будет печатать тут).
  vim.fn.setline(crow, indent .. one_shift())
  -- Ниже — "<% end %>" с отступом открывашки.
  vim.fn.append(crow, indent .. "<% end %>")
  -- Курсор в конец отступленной строки.
  vim.fn.cursor(crow, #(indent .. one_shift()) + 1)
end

-- Именованный namespace -> при повторном :source файла колбэк заменяется, а не
-- накапливается (иначе на каждый Enter срабатывало бы несколько копий).
local ns = vim.api.nvim_create_namespace("erb_endwise")
vim.on_key(function(key)
  if key ~= "\r" then
    return
  end
  if vim.api.nvim_get_mode().mode ~= "i" then
    return
  end
  if vim.bo.filetype ~= "eruby" then
    return
  end
  -- не вмешиваться в проигрывание/запись макросов
  if vim.fn.reg_executing() ~= "" or vim.fn.reg_recording() ~= "" then
    return
  end
  -- Enter ещё не обработан в момент колбэка — откладываем до конца цикла,
  -- когда перевод строки уже вставлен.
  vim.schedule(function()
    if vim.bo.filetype == "eruby" then
      maybe_insert_erb_end()
    end
  end)
end, ns)
