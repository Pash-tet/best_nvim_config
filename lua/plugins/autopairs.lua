return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- незачем грузить плагин, пока не зашёл в insert-режим
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({})

    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    -- Пара "|...|" вокруг параметров Ruby-блока: `do |a|` или `{ |a| }`.
    -- НЕ трогаем обычный "|"/"||" как оператор (a || b, a | b) — пара
    -- ставится, только если непосредственно перед курсором стоит "do"
    -- или "{" (с необязательными пробелами перед курсором).
    autopairs.add_rule(
      Rule("|", "|", { "ruby", "eruby" })
        :with_pair(function(opts)
          local before_cursor = opts.line:sub(1, opts.col - 1)
          -- %f[%w] — "frontier": пустая позиция на границе (не-слово -> слово).
          -- Без неё "do%s*$" сматчилось бы и на хвост "todo"/"redo" и вставило
          -- бы пару там, где | это оператор. С frontier "do" должно быть
          -- отдельным словом (перед ним пробел/скобка/начало строки).
          return before_cursor:match("%f[%w]do%s*$") ~= nil
            or before_cursor:match("{%s*$") ~= nil
        end)
        :with_move(cond.done()) -- повторный "|" просто перескакивает через уже вставленный, не дублирует
    )

    -- ERB-теги: <% %>. Курсор после срабатывания встаёт МЕЖДУ "<%" и " %>",
    -- поэтому если дальше напечатать "=" или "#" — получится "<%=" / "<%#"
    -- перед уже вставленным " %>", то есть <%= %> и <%# %> само сложится
    -- без отдельных правил на "<%=" и "<%#" (и без риска задвоить пару).
    autopairs.add_rule(Rule("<%", " %>", "eruby"))
  end,
}
