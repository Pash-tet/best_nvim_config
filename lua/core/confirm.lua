-- Свой y/n/c-диалог на nui.nvim (уже установлен как зависимость noice.nvim).
--
-- ПОЧЕМУ НЕ vim.fn.confirm() / ":confirm quit": на Neovim 0.11+ встроенный
-- confirm() рендерится через внутренний cmdline-цикл. noice.nvim корректно
-- стилизует только САМЫЙ ПЕРВЫЙ показ (событие с меткой kind="confirm").
-- Если пользователь жмёт клавишу, отличную от y/n/c, Neovim повторно
-- перерисовывает тот же диалог БЕЗ этой метки — noice принимает редроу за
-- обычный ввод команды и рисует другое, "неправильное" окно (без заголовка
-- "Confirm", другой стиль). Это подтверждённое ограничение самого noice
-- (см. Cmdline.handle_confirm в его исходнике — жёстко привязано к версии
-- nvim, не настраивается). Собственный попап решает проблему в корне: мы
-- сами решаем, какие клавиши что-то делают, а остальные просто НЕ ИМЕЮТ
-- маппинга — Neovim их тихо проглатывает, никакого повторного рендера нет.

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

--- @param message string текст вопроса, например 'Save changes to "x.rb"?'
--- @param on_choice fun(choice: "yes"|"no"|"cancel")
function M.ask(message, on_choice)
  local hint = "[Y]es   (N)o   (C)ancel"
  local width = math.max(#message, #hint) + 4

  local popup = Popup({
    enter = true, -- фокус сразу в попап — иначе клавиши y/n/c уйдут в исходный буфер
    focusable = true,
    border = {
      style = "rounded",
      text = { top = " Confirm ", top_align = "center" },
    },
    relative = "editor",
    position = "50%", -- центр экрана — как и было в дефолтном confirm-виде noice
    size = { width = width, height = 3 },
    buf_options = {
      buftype = "nofile", -- не настоящий файл — не попадёт в буфер-лист, не сохранится по ошибке
      swapfile = false,
    },
    win_options = {
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
    },
  })

  popup:mount()

  -- Контент пишем ДО того, как выключить modifiable — nvim_buf_set_lines
  -- требует modifiable=true, иначе ошибка.
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
    message,
    hint,
  })
  vim.bo[popup.bufnr].modifiable = false
  vim.bo[popup.bufnr].readonly = true

  local done = false
  local function finish(choice)
    if done then
      return -- защита от двойного срабатывания (например, BufLeave ПОСЛЕ явного выбора)
    end
    done = true
    popup:unmount()
    on_choice(choice)
  end

  local opts = { noremap = true, nowait = true }
  popup:map("n", { "y", "Y", "<CR>" }, function()
    -- <CR> — как и в нативном vim.fn.confirm(): Enter выбирает вариант,
    -- помеченный заглавной буквой в подсказке ("[Y]es"), то есть "да".
    finish("yes")
  end, opts)
  popup:map("n", { "n", "N" }, function()
    finish("no")
  end, opts)
  popup:map("n", { "c", "C", "<Esc>" }, function()
    finish("cancel")
  end, opts)

  -- ГЛАВНАЯ ЧАСТЬ ФИКСА: изначально план был "остальные клавиши просто не
  -- замаплены — Neovim их проглотит". Оказалось, это неверно: буквы и цифры
  -- почти все что-то ЗНАЧАТ в normal-режиме (x=удалить, d/c=операторы,
  -- gg=перейти в начало и т.д.) — они долетают до нативного обработчика и,
  -- натыкаясь на readonly-буфер, кидают настоящую Vim-ошибку (E21). А с
  -- cmdheight=0 (core/options.lua) такая ошибка иногда требует подтверждения
  -- "нажми любую клавишу" и СЪЕДАЕТ следующее нажатие — то есть попап всё
  -- ещё цел, но y/n/c с первого раза может не сработать. Поэтому явно
  -- гасим <Nop>'ом все буквы и цифры, кроме y/n/c — теперь они АБСОЛЮТНО
  -- ничего не делают, ни один нативный обработчик их не увидит.
  local nop_chars = "abdefghijklmopqrstuvwxzABDEFGHIJKLMOPQRSTUVWXZ0123456789"
  for i = 1, #nop_chars do
    popup:map("n", nop_chars:sub(i, i), "<Nop>", opts)
  end

  -- Если фокус ушёл из попапа (например, кликом мышью) — считаем это отменой,
  -- чтобы диалог не завис невидимым/недоступным для управления.
  popup:on(event.BufLeave, function()
    finish("cancel")
  end)
end

return M
