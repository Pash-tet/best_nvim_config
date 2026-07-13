return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      -- Ruby СОЗНАТЕЛЬНО не линтуем через rubocop здесь: диагностику Ruby даёт
      -- ruby-lsp (парсер Prism) — синтаксис, unused var и т.д. Держать ещё и
      -- rubocop в nvim-lint = дубли (например "unused variable" от обоих сразу).
      -- Компромисс: без rubocop уходит бОльшая часть style-правил — если позже
      -- захочешь их вернуть, тут снова добавляем ruby = { "rubocop" }.
      python = { "ruff" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
    }

    -- Когда запускать линтер:
    --   BufReadPost  — сразу при ОТКРЫТИИ файла (чтобы ошибки были видны до
    --                  первого сохранения),
    --   BufWritePost — после сохранения (файл поменялся — перепроверить),
    --   InsertLeave  — вышел из режима вставки (быстрая обратная связь по ходу).
    -- diagnostics LSP и так есть, это ДОПОЛНИТЕЛЬНЫЕ проверки (rubocop-правила).
    -- augroup + clear=true — как в core/autocmds.lua: без группы после :source
    -- конфига автокоманда зарегистрируется второй раз, и линтер погонится дважды.
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })

    -- Гонка ленивой загрузки: плагин грузится по BufReadPost (см. event выше),
    -- то есть config() выполняется в РАЗГАР обработки BufReadPost для текущего
    -- файла — автокоманда выше его уже не поймает, а если позвать try_lint()
    -- прямо тут, синхронно, filetype может быть ещё НЕ выставлен в "ruby"
    -- (определение ft — тоже автокоманда на этом же событии) и линт уйдёт
    -- впустую. vim.schedule откладывает вызов до конца текущего цикла событий,
    -- когда ft уже проставлен. Это разовый линт для самого первого файла.
    vim.schedule(function()
      lint.try_lint()
    end)
  end,
}
