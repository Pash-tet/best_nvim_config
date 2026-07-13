return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy", -- statusline не нужен в первую миллисекунду запуска
  opts = {
    options = {
      theme = "tokyonight", -- у lualine есть готовая тема под нашу colorscheme
      -- "иконки-разделители" между секциями (a|b|c ... x|y|z) — нужен nerd font,
      -- он у нас уже настроен (см. core/diagnostics.lua)
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      -- branch — читает git-ветку. Работает и БЕЗ gitsigns (у lualine своя
      -- логика чтения .git/HEAD), а когда позже поставим gitsigns.nvim —
      -- заодно появятся live-значки added/modified/removed в этой же секции.
      lualine_b = { "branch" },
      -- diagnostics — берёт счётчики из ТОГО ЖЕ vim.diagnostic, что мы уже
      -- настраивали (core/diagnostics.lua): LSP + nvim-lint одним потоком.
      -- Иконки те же codepoints, что и в signs.text — statusline и gutter
      -- показывают одинаковые значки для одного и того же уровня severity.
      lualine_c = {
        "filename",
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
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
