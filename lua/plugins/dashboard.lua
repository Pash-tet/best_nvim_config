return {
  "goolord/alpha-nvim",
  event = "VimEnter", -- показать дашборд ДО того, как что-либо ещё займёт экран
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    return require("alpha.themes.theta").config
  end,
  config = function(_, opts)
    require("alpha").setup(opts)
  end,
}
