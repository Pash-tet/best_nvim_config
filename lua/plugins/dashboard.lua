return {
  "goolord/alpha-nvim",
  event = "VimEnter", -- показать дашборд ДО того, как что-либо ещё займёт экран
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    local theta = require("alpha.themes.theta")

    -- Добавляем кнопку Restore Session ПЕРЕД Quit в списке кнопок theta.
    -- theta.buttons.val: text "Quick links" (1), padding (2), затем кнопки
    -- e/SPC f f/SPC f g/c/u/q — вставка перед последней (Quit).
    table.insert(theta.buttons.val, #theta.buttons.val,
      dashboard.button("s", "  Restore Session", "<cmd>lua require('persistence').load()<cr>"))

    return theta.config
  end,
  config = function(_, opts)
    require("alpha").setup(opts)
  end,
}
