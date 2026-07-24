return {
  "folke/lazydev.nvim",
  ft = "lua", -- грузится только на lua-файлах (наш собственный конфиг и есть такой случай)
  opts = {
    library = {
      -- подгружает типы luv (vim.uv.*) по требованию, если это слово встречается в файле
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      -- типы snacks.nvim: убирает "Undefined global Snacks" в наших плагинах
      -- (snacks.lua, bufferline.lua, neo-tree.lua дёргают глобал Snacks)
      { path = "snacks.nvim", words = { "Snacks" } },
    },
  },
}
