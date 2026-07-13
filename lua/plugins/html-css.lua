-- Автокомплит CSS class/id в html-подобных шаблонах для НЕ-tailwind проектов
-- (Bulma, свои классы, обычный CSS). Tailwind покрывается отдельно
-- tailwindcss-language-server (см. lua/plugins/lsp.lua).
--
-- Плагин работает КАК LSP-сервер (html-css-lsp) и подключается через уже
-- включённый источник "lsp" в blink.cmp — отдельный провайдер в completion.lua
-- НЕ нужен. Классы берёт из инлайновых <style>, тегов <link rel=stylesheet> в
-- буфере и путей/URL из style_sheets. ВАЖНО: css-стили он парсит treesitter-
-- парсером "css" — поэтому "css" добавлен в install-список treesitter.lua.
--
-- Про slim: плагин ищет контекст класса в дереве lang="html". У slim СВОЯ
-- грамматика без html-дерева, поэтому класс-комплит здесь плагин НЕ даёт. Для
-- slim классы приходят от tailwind (когда проект на tailwind); Bulma/свой-css в
-- slim этим плагином не покрывается — известное ограничение.
return {
  "Jezda1337/nvim-html-css",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "html", "eruby" }, -- lazy-триггер по FILETYPE (.erb → eruby)
  -- ШИМ для .erb регистрируем в init (на СТАРТЕ, до открытия файлов), а не в
  -- config: плагин грузится лениво по ft, и config бежит уже ПОСЛЕ FileType
  -- текущего буфера — autocmd опоздал бы на самый первый .erb.
  -- Зачем шим: плагин определяет контекст класса через get_node({lang="html"}).
  -- У .erb парсер — embedded_template, html там combined-инъекция, в которую
  -- get_node{lang} НЕ спускается (возвращает content) — классы не отдавались.
  -- Обход: заводим на буфере ОТДЕЛЬНЫЙ html-парсер, тогда get_node{lang="html"}
  -- находит html-дерево. Два нюанса (найдены опытом): без начального parse()
  -- дерева ещё нет; ссылку надо УДЕРЖАТЬ, иначе парсер собирает GC. Поэтому
  -- парсим сразу и держим ссылки в таблице (чистим на BufDelete). На highlight
  -- не влияет — там свой embedded_template.
  init = function()
    local html_parsers = {}
    local function ensure_html_tree(buf)
      if html_parsers[buf] then
        return
      end
      local ok, parser = pcall(vim.treesitter.get_parser, buf, "html")
      if ok and parser then
        parser:parse(true)
        html_parsers[buf] = parser
      end
    end
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("html_css_erb_html_tree", { clear = true }),
      pattern = "eruby",
      callback = function(ev)
        -- vim.schedule: создаём html-парсер ПОСЛЕ того как осядет каскад FileType
        -- (иначе, синхронно во время инициализации embedded_template, дерево не
        -- «прилипает» и get_node{lang=html} остаётся nil).
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            ensure_html_tree(ev.buf)
          end
        end)
      end,
    })
    vim.api.nvim_create_autocmd("BufDelete", {
      group = vim.api.nvim_create_augroup("html_css_erb_html_tree_cleanup", { clear = true }),
      callback = function(ev)
        html_parsers[ev.buf] = nil
      end,
    })
  end,
  opts = {
    -- enable_on — это СПИСОК РАСШИРЕНИЙ ФАЙЛОВ, не filetypes! Плагин строит
    -- автокоманду по паттерну "*."..ext и сверяет %:t:e. Поэтому для .erb здесь
    -- именно "erb" (расширение), а не "eruby" (filetype). Матчит и "page.html.erb".
    enable_on = { "html", "erb" },

    -- style_sheets — глобальный список стилей. СОЗНАТЕЛЬНО пуст: один жёсткий
    -- список не подходит всем проектам. Основной путь — автоподхват <link>/<style>
    -- из буфера. Если стили не в <link> (собраны в asset pipeline) — добавь сюда
    -- CDN или путь к СКОМПИЛИРОВАННОМУ css. Примеры:
    --   "https://cdn.jsdelivr.net/npm/bulma@1/css/bulma.min.css", -- Bulma по CDN
    --   "./app/assets/builds/application.css",                    -- свой/скомпилированный css
    -- Пути резолвятся от cwd. ВНИМАНИЕ: .scss/.sass плагин НЕ парсит — указывай
    -- именно css-выход сборки. Также поддерживается per-project .nvim.lua с
    -- vim.g.html_css = { style_sheets = {...} }.
    --
    -- ЕЩЁ ВАЖНО: инлайновый <style> кэшируется только если в буфере/конфиге есть
    -- ХОТЯ БЫ ОДИН внешний источник (плагин делает ранний return при пустом
    -- списке источников). То есть <style> без <link>/style_sheets классов не даст.
    style_sheets = {},
  },
}
