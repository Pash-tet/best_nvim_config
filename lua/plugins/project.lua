return {
  -- project.nvim автоматически запоминает посещённые проекты: при открытии
  -- файла ищет корень проекта и (а) делает :cd в него, (б) записывает его в
  -- историю (~/.local/share/nvim/project_nvim/project_history). Руками ничего
  -- добавлять не нужно — список наполняется сам по мере работы.
  -- Смотрим список через :Projects (наш пикер ниже): <leader>fp или кнопка "p"
  -- на дашборде. Выбор проекта = cd + восстановление его сессии (persistence).
  "ahmedkhalf/project.nvim",
  -- VeryLazy, а не lazy-on-key: плагин должен работать с самого запуска,
  -- чтобы ЗАПИСЫВАТЬ проекты в историю, а не только показывать пикер.
  event = "VeryLazy",
  keys = {
    { "<leader>fp", "<cmd>Projects<CR>", desc = "Projects" },
  },
  config = function()
    -- Имя lua-модуля не совпадает с именем репозитория (project.nvim ->
    -- project_nvim), поэтому opts/автодетект lazy.nvim не сработает — setup руками.
    require("project_nvim").setup({
      -- Только по маркеру .git: дефолтный набор (Makefile, package.json, ...)
      -- цепляется за подпапки монорепы и мусорные каталоги, а lsp-метод
      -- дёргает cwd в зависимости от того, какой сервер поднялся первым.
      detection_methods = { "pattern" },
      patterns = { ".git" },
    })

    -- Плагин грузится на VeryLazy — это ПОЗЖЕ, чем VimEnter/BufEnter стартового
    -- буфера (`nvim файл.rb`), поэтому автокоманды плагина его пропускают и
    -- проект НЕ записывается, пока не перейдёшь в другой буфер. Прогоняем
    -- детект руками один раз сразу после загрузки — для уже открытого буфера.
    require("project_nvim.project").on_buf_enter()

    -- Свой пикер вместо голого :Telescope projects — его дефолтный Enter
    -- делает cd + find_files, а нам нужно cd + восстановить сессию проекта.
    vim.api.nvim_create_user_command("Projects", function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      require("telescope").extensions.projects.projects({
        attach_mappings = function(prompt_bufnr)
          -- replace() внутри attach_mappings действует только на этот пикер:
          -- telescope откатывает подменённые action'ы после закрытия.
          actions.select_default:replace(function()
            local entry = action_state.get_selected_entry()
            if not entry then
              return
            end
            actions.close(prompt_bufnr)
            vim.fn.chdir(entry.value)
            -- Сессия есть — восстанавливаем (persistence ищет её по новому
            -- cwd). Нет (первый заход в проект) — просто открываем поиск
            -- файлов, чтобы не оставлять пустой экран.
            local persistence = require("persistence")
            local session = persistence.current()
            if session and vim.fn.filereadable(session) == 1 then
              persistence.load()
            else
              vim.notify("Сессии для проекта нет — открываю поиск файлов", vim.log.levels.INFO)
              require("telescope.builtin").find_files()
            end
          end)
          return true
        end,
      })
    end, { desc = "Пикер проектов: cd + restore session" })
  end,
}
