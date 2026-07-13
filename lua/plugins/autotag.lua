return {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    aliases = {
      -- в списке поддерживаемых языков нет eruby "из коробки" — говорим
      -- плагину обращаться с HTML-частью .erb так же, как с обычным html
      eruby = "html",
    },
  },
}
