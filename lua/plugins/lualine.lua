return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy", -- statusline не нужен в первую миллисекунду запуска
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- иконки типов файлов в секции c
  opts = {
    options = {
      -- "auto" — lualine собирает палитру из АКТИВНОЙ colorscheme, а не из
      -- жёстко зашитого имени темы. Важно именно у нас: <leader>uc (см.
      -- lua/plugins/telescope.lua) — живой пикер тем с превью, и с "auto"
      -- статуслайн перекрашивается ВСЛЕД за превью; с жёстким именем он
      -- остался бы в палитре одной темы независимо от выбранной схемы.
      -- Раньше здесь стояло "tokyonight" — осталось с тех пор, когда активной
      -- была tokyonight. После перехода на catppuccin-nvim статуслайн
      -- продолжал рисоваться палитрой ЧУЖОЙ темы (у catppuccin своя lualine-
      -- тема есть — lua/lualine/themes/catppuccin-nvim.lua, — но "auto"
      -- избавляет от необходимости помнить про эту связку вообще).
      theme = "auto",
      -- ОДНА общая строка на весь редактор (у нас laststatus=3 в core/options.lua),
      -- а не отдельный statusline на каждый сплит — как в LazyVim (globalstatus).
      globalstatus = true,
      -- на стартовом экране (alpha) statusline лишний
      disabled_filetypes = { statusline = { "alpha" } },
      -- powerline-разделители между секциями — нужен nerd font (у нас настроен,
      -- см. core/diagnostics.lua). ВАЖНО: пишем глифы через \u{...}-escape, а не
      -- литералами — литеральные PUA-символы могут потеряться при записи файла
      -- (превратиться в пустую строку — тогда уголки просто не рисуются).
      -- section  = "жирные" уголки между a/b/c…, component = тонкие внутри секции.
      section_separators = { left = "\u{E0B0}", right = "\u{E0B2}" },
      component_separators = { left = "\u{E0B1}", right = "\u{E0B3}" },
    },
    sections = {
      lualine_a = { "mode" },
      -- branch — читает git-ветку. Работает и БЕЗ gitsigns (у lualine своя
      -- логика чтения .git/HEAD), а gitsigns.nvim (у нас есть) даёт live-diff —
      -- он ниже, в секции x.
      lualine_b = { "branch" },
      lualine_c = {
        -- иконка типа файла ОТДЕЛЬНЫМ компонентом (icon_only), вплотную к имени —
        -- как в LazyVim: сначала цветной значок, затем путь.
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        -- path=1 — путь ОТНОСИТЕЛЬНО cwd (lua/plugins/lualine.lua), а не голое имя.
        { "filename", path = 1 },
        -- diagnostics — берёт счётчики из ТОГО ЖЕ vim.diagnostic, что мы уже
        -- настраивали (core/diagnostics.lua): LSP + nvim-lint одним потоком.
        -- Иконки те же codepoints, что и в signs.text — statusline и gutter
        -- показывают одинаковые значки для одного уровня severity.
        {
          "diagnostics",
          symbols = {
            error = "\u{F057} ",
            warn = "\u{F071} ",
            info = "\u{F05A} ",
            hint = "\u{F0EB} ",
          },
        },
      },
      lualine_x = {
        -- статус команды noice (запись макроса @, ввод :cmd и т.п.) — фирменная
        -- деталь LazyVim. Появляется ТОЛЬКО когда noice реально что-то показывает,
        -- иначе секция пустая (cond).
        {
          function()
            return require("noice").api.status.command.get()
          end,
          cond = function()
            return package.loaded["noice"] and require("noice").api.status.command.has()
          end,
        },
        -- git-diff: added/modified/removed по ТЕКУЩЕМУ буферу. Источник —
        -- gitsigns (live-счётчики через vim.b.gitsigns_status_dict). Иконки —
        -- те же codepoints, что использует LazyVim.
        {
          "diff",
          symbols = {
            added = "\u{F0FE} ",
            modified = "\u{F14B} ",
            removed = "\u{F146} ",
          },
          source = function()
            local gs = vim.b.gitsigns_status_dict
            if gs then
              return { added = gs.added, modified = gs.changed, removed = gs.removed }
            end
          end,
        },
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      -- часы в самой правой секции — как на скриншоте LazyVim (13:49).
      lualine_z = {
        function()
          return "\u{F017} " .. os.date("%R")
        end,
      },
    },
    extensions = { "lazy" }, -- аккуратный statusline на окне :Lazy
  },
}
