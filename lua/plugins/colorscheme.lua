-- Один файл в lua/plugins/ = один или несколько plugin spec'ов (return список таблиц).
-- lazy.nvim подхватит этот файл автоматически благодаря { import = "plugins" }
return {
  {
    "catppuccin/nvim", -- репозиторий буквально называется "nvim"
    name = "catppuccin", -- явное имя, иначе lazy.nvim склонировал бы его в папку "nvim"
    priority = 1000, -- грузить ПЕРВЫМ (до других плагинов) — важно для цветовых схем
    opts = {
      flavour = "macchiato", -- выбор пользователя (из 4: latte/frappe/macchiato/mocha)
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- ВАЖНО (сверено по актуальному README, не по памяти): начиная с
      -- Neovim 0.12 в редактор ВШИТА своя колор-схема "catppuccin" (другого
      -- авторства, другой стиль) — чтобы не столкнуться с ней, у ЭТОГО
      -- плагина имя команды теперь "catppuccin-nvim" (colors/catppuccin-
      -- nvim.vim, алиас на тот же loader, читает flavour из setup() выше),
      -- а не голое "catppuccin". У нас как раз nvim 0.12.4 — коллизия реальная.
      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },

  -- Оставлены "на пробу" (пользователь оставил себе возможность
  -- переключиться через `:Telescope colorschemes` — живое превью, см.
  -- <leader>uc в telescope.lua) — gruvbox-material/sonokai/monokai-pro
  -- убраны по его же явной просьбе. lazy=false + priority=1000: без
  -- lazy-триггера (keys/cmd/event/ft) lazy.nvim и так загрузил бы их при
  -- старте, но пишем явно для читаемости — colors/ должен попасть в
  -- runtimepath ДО того, как `:colorscheme` попробует его найти.
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  -- kanagawa: "kanagawa" — авто-вариант (смотрит на background), плюс
  -- отдельные colors/kanagawa-wave|dragon|lotus.vim под конкретный вариант.
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
}
