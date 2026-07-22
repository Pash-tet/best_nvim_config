return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} }, -- сам менеджер: качает бинарники серверов
      "neovim/nvim-lspconfig", -- готовые конфиги (cmd, root_markers) для сотен серверов
    },
    opts = {
      -- mason-lspconfig сам скачает эти сервера через mason И сам вызовет
      -- vim.lsp.enable() для каждого — вручную .setup{} по-старому не нужен
      -- ruby_lsp здесь НЕТ сознательно: у нас mise с кучей ruby под проекты, а
      -- mason ставит gem в ОДНУ (глобальную) ruby. Открыл проект на другой
      -- версии — сервер либо не тот, либо отсутствует. Вместо этого ruby-lsp
      -- берём из ruby самого проекта (mise-шим `ruby-lsp`) — конфиг+enable ниже,
      -- в блоке nvim-lspconfig. ВАЖНО: mason.PATH="prepend" кладёт mason/bin
      -- ПЕРЕД mise в PATH, так что если пакет ruby-lsp (или rubocop) когда-то
      -- случайно доставили через :Mason — он молча перебьёт мисовый шим и всю
      -- эту логику. Держи их удалёнными из mason (`:Mason` → x).
      ensure_installed = {
        "lua_ls", -- Lua (наш собственный конфиг)
        "pyright", -- Python
        "ts_ls", -- JS/TypeScript
        "bashls", -- Bash
        -- tailwindcss — автокомплит tailwind-классов (в т.ч. в .erb/.slim: eruby
        -- и slim уже в дефолтных filetypes сервера). Активируется ТОЛЬКО когда в
        -- корне проекта есть tailwind-признак (tailwind.config.*, postcss.config.*,
        -- Gemfile.lock/package.json с полем tailwind, v4 — @import "tailwindcss").
        -- В проектах на Bulma/обычном CSS сервер просто не стартует — там классы
        -- даёт nvim-html-css (см. lua/plugins/html-css.lua).
        "tailwindcss", -- Tailwind CSS
        -- stimulus_ls — автокомплит/переходы для Stimulus-контроллеров
        -- (data-controller/data-action/data-target в html/erb/slim). Активация
        -- строго условная (см. stimulus_root ниже) — как и у tailwindcss.
        "stimulus_ls",
        "jsonls", -- JSON: валидация + автокомплит по JSON Schema (см. schemastore ниже)
      },
    },
  },

  -- Раньше здесь был костыль vim.lsp.config("lua_ls", {settings={Lua={diagnostics={globals={"vim"}}}}}),
  -- который просто ЗАГЛУШАЛ предупреждение "undefined global vim".
  -- lazydev.nvim (см. lua/plugins/lazydev.lua) решает это правильно —
  -- подключает lua_ls к настоящим типам vim.* API, а не просто прячет warning.

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- schemastore.nvim — не LSP-сервер, а просто база готовых JSON/YAML-схем
      -- (package.json, tsconfig.json, .eslintrc и сотни других). jsonls сам
      -- схем не знает — без этого пакета он умеет только базовый JSON-синтаксис.
      "b0o/schemastore.nvim",
    },
    config = function()
      -- '*' — специальный конфиг, применяется КО ВСЕМ серверам сразу.
      -- Без этого LSP-серверы не будут знать, что клиент (blink.cmp) умеет
      -- принимать более широкие данные (например, сниппеты в автодополнении).
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- jsonls: схемы из schemastore подключаем явно — сам сервер их не грузит.
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- ruby-lsp вне mason (см. комментарий в mason-lspconfig выше). cmd =
      -- "ruby-lsp" — это mise-шим: он резолвится в ruby, запиннутую для ТЕКУЩЕГО
      -- проекта (.tool-versions/mise.toml), так что каждый проект получает свой
      -- сервер под свою версию. Сам ruby-lsp дальше умно собирает кастомный
      -- бандл проекта. Требование: gem ruby-lsp должен быть установлен в тех
      -- ruby, которыми пользуешься (`gem install ruby-lsp`; чтобы ставился
      -- автоматически в каждую новую ruby — добавь строку "ruby-lsp" в
      -- ~/.default-gems).
      -- mason-lspconfig сервер вне ensure_installed сам не включит — enable вручную.
      --
      -- positionEncodings: ruby-lsp (через prism) при utf-8 считает длины
      -- semantic-token'ов в СИМВОЛАХ вместо БАЙТОВ (баг в Prism::CodeUnitsCache
      -- ::LengthCounter — использует String#length, а LSP-протокол при utf-8
      -- требует байты). После любого multibyte-символа в строке (кириллица,
      -- "·", эмодзи) все токены дальше по строке съезжают на 1 и обрезают
      -- подсветку последнего символа слова. Отбираем "utf-8" из предлагаемых
      -- клиентом encoding'ов ТОЛЬКО для этого сервера — тогда он выбирает
      -- utf-16, где используется корректный UTF16Counter, а Neovim сам
      -- пересчитывает utf-16 code units обратно в байты буфера.
      local ruby_capabilities = vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), {})
      ruby_capabilities.general = ruby_capabilities.general or {}
      ruby_capabilities.general.positionEncodings = { "utf-16" }
      vim.lsp.config("ruby_lsp", { capabilities = ruby_capabilities })
      vim.lsp.enable("ruby_lsp")

      -- ts_ls (typescript-language-server): дефолтные root_markers включают
      -- package.json/.git/tsconfig/jsconfig, поэтому сервер лезет в КАЖДЫЙ
      -- JS-проект — в т.ч. с jsconfig.json БЕЗ TypeScript (jsconfig — валидный
      -- маркер для чистого JS, tsserver его тоже подхватывает). Но сам
      -- typescript-language-server не бандлит компилятор: ему нужен реально
      -- установленный npm-пакет "typescript" в workspace (node_modules/typescript)
      -- — без него initialize падает с RPC-ошибкой "Could not find a valid
      -- TypeScript installation" (именно её мы и ловили). Поэтому единственный
      -- надёжный гейт — не наличие конфигов, а фактическая установка пакета.
      local function ts_root(fname)
        local root = vim.fs.root(fname, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
        if root and vim.fn.isdirectory(root .. "/node_modules/typescript") == 1 then
          return root
        end
        return nil
      end

      vim.lsp.config("ts_ls", {
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          if fname == "" then
            return
          end
          local root = ts_root(fname)
          if root then
            on_dir(root)
          end
        end,
      })

      -- tailwindcss: СТРОГАЯ активация. Дефолтный root_dir сервера падает на
      -- fallback по .git (для tailwind v4), из-за чего сервер цеплялся к КАЖДОМУ
      -- git-репозиторию — в т.ч. к Bulma/обычным проектам, где tailwind нет
      -- (лишний node-процесс на каждый проект). Требуем реальный tailwind-маркер:
      --   1) конфиг tailwind/postcss (v3 и большинство сетапов),
      --   2) манифест с зависимостью tailwind (npm-пакет / гем tailwindcss-rails),
      --   3) css с @import "tailwindcss" / @tailwind (v4 без конфиг-файла).
      -- vim.fs.root идёт от файла ВВЕРХ по предкам и берёт первый каталог с
      -- маркером; если ни одного нет — on_dir не зовём, и сервер не стартует.
      local function tailwind_root(fname)
        local root = vim.fs.root(fname, {
          "tailwind.config.js",
          "tailwind.config.cjs",
          "tailwind.config.mjs",
          "tailwind.config.ts",
          "postcss.config.js",
          "postcss.config.cjs",
          "postcss.config.mjs",
          "postcss.config.ts",
        })
        if root then
          return root
        end
        root = vim.fs.root(fname, function(name, path)
          if name ~= "package.json" and name ~= "Gemfile.lock" then
            return false
          end
          local ok, lines = pcall(vim.fn.readfile, path .. "/" .. name)
          return ok and table.concat(lines, "\n"):match("tailwind") ~= nil
        end)
        if root then
          return root
        end
        -- 3) v4 без конфига/манифеста: css с @import "tailwindcss"/@tailwind.
        -- Такой css обычно лежит в ПОДкаталоге (app/assets, src…), поэтому вверх
        -- по предкам его не найти — сначала берём границу проекта (.git/манифест),
        -- затем ищем ВНИЗ по типовым style-каталогам (node_modules не трогаем).
        local proj = vim.fs.root(fname, { ".git", "Gemfile", "package.json" })
        if not proj then
          return nil
        end
        local style_globs = {
          "*.css",
          "app/assets/**/*.css",
          "app/frontend/**/*.css",
          "src/**/*.css",
          "assets/**/*.css",
          "styles/**/*.css",
          "stylesheets/**/*.css",
        }
        for _, glob in ipairs(style_globs) do
          for _, css in ipairs(vim.fn.globpath(proj, glob, true, true)) do
            local ok, lines = pcall(vim.fn.readfile, css)
            if ok then
              local content = table.concat(lines, "\n")
              if content:match("@import%s+[\"']tailwindcss") ~= nil or content:match("@tailwind%s") ~= nil then
                return proj
              end
            end
          end
        end
        return nil
      end

      vim.lsp.config("tailwindcss", {
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          if fname == "" then
            return
          end
          local root = tailwind_root(fname)
          if root then
            on_dir(root)
          end
        end,
      })

      -- stimulus_ls: та же логика строгой активации, что у tailwindcss —
      -- дефолтный root_markers сервера ({'Gemfile', '.git'}) зацепился бы к
      -- ЛЮБОМУ ruby/git-проекту, даже без Stimulus вовсе. Признак реального
      -- использования Stimulus: гем stimulus-rails/importmap-rails+stimulus
      -- в Gemfile(.lock), npm-пакет @hotwired/stimulus в package.json, либо
      -- типовая rails-конвенция app/javascript(/app/frontend)/controllers.
      local function stimulus_root(fname)
        local proj = vim.fs.root(fname, { ".git", "Gemfile", "package.json" })
        if not proj then
          return nil
        end
        local function manifest_mentions_stimulus(name)
          local ok, lines = pcall(vim.fn.readfile, proj .. "/" .. name)
          return ok and table.concat(lines, "\n"):match("stimulus") ~= nil
        end
        if
          manifest_mentions_stimulus("Gemfile")
          or manifest_mentions_stimulus("Gemfile.lock")
          or manifest_mentions_stimulus("package.json")
        then
          return proj
        end
        for _, dir in ipairs({
          "app/javascript/controllers",
          "app/frontend/controllers",
        }) do
          if vim.fn.isdirectory(proj .. "/" .. dir) == 1 then
            return proj
          end
        end
        return nil
      end

      vim.lsp.config("stimulus_ls", {
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          if fname == "" then
            return
          end
          local root = stimulus_root(fname)
          if root then
            on_dir(root)
          end
        end,
      })

      -- LSP-кеймапы в стиле LazyVim. Вешаем ПО СОБЫТИЮ LspAttach (буфер-локально
      -- на файлы, где реально подключился сервер), а не глобально.
      -- ВАЖНО про совместимость со встроенными кеймапами nvim: мы СОЗНАТЕЛЬНО НЕ
      -- маппим одиночный "gr" (references). У Neovim 0.11+ встроены gr-префиксные
      -- кеймапы: grr (references), grn (rename), gra (code action), gri
      -- (implementation). Если замапить "gr" целиком — они бы сломались/затупили
      -- (ambiguity с gr-префиксом). Поэтому: goto-definition/impl/type-def
      -- добавляем на СВОБОДНЫЕ клавиши gd/gI/gy (через telescope-пикеры), а
      -- references/rename/code-action остаются на родных grr/grn/gra — они и есть
      -- LazyVim-эквиваленты. Плюс дублируем rename/action под <leader>c-группу.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_lazyvim_keymaps", { clear = true }),
        callback = function(ev)
          local tb = require("telescope.builtin")
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd", tb.lsp_definitions, "Goto Definition")
          map("gI", tb.lsp_implementations, "Goto Implementation")
          map("gy", tb.lsp_type_definitions, "Goto Type Definition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cl", function()
            vim.cmd("checkhealth vim.lsp")
          end, "LSP info")
        end,
      })
    end,
  },
}
