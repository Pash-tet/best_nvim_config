return {
  "folke/snacks.nvim",
  -- lazy=false + высокий priority — как у LazyVim самого core-спека snacks.nvim
  -- (сверено по исходнику lazyvim/plugins/init.lua): Snacks — общая
  -- utility-библиотека (rename, notify и т.п.), на неё полагаются другие
  -- плагины (напр. neo-tree.lua дёргает Snacks.rename при переименовании
  -- файла в дереве) — она должна существовать к моменту, когда до неё
  -- дотянутся, а не только после первого нажатия своих собственных keys.
  lazy = false,
  priority = 1000,
  opts = {
    -- explorer убран — вернулись на neo-tree.nvim (см. lua/plugins/neo-tree.lua),
    -- у которого есть полноценный git_status-источник (LazyVim ставит его как
    -- opt-in extra именно за это). Snacks остаётся ради терминала + Snacks.rename.
    terminal = {
      win = {
        position = "bottom",
        height = 0.3,
      },
    },
    -- scratch-буферы: постоянные (сохраняются в ~/.local/share/nvim/scratch/),
    -- привязаны к cwd+ветке+ft — по <leader>. открывается тот же буфер для
    -- текущего проекта, удобно как черновик/repl.
    scratch = { enabled = true },
  },
  keys = {
    -- Группа scratch на префиксе <leader>z (мнемоника «z»). Плейн zz/ze/zd
    -- не трогаем — это встроенные команды Vim (zz центрирует экран и т.п.).
    {
      "<leader>zz",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>ze",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    -- Удаление текущего scratch: snacks хранит их как файлы в
    -- ~/.local/share/nvim/scratch/ (сам файл + напарник .meta), встроенной
    -- команды delete нет — сносим оба файла и закрываем буфер вручную.
    {
      "<leader>zd",
      function()
        local file = vim.api.nvim_buf_get_name(0)
        if file:match("/scratch/") then
          vim.fn.delete(file)
          vim.fn.delete(file .. ".meta")
          vim.cmd("bdelete!")
          vim.notify("Scratch удалён", vim.log.levels.INFO)
        else
          vim.notify("Это не scratch-буфер", vim.log.levels.WARN)
        end
      end,
      desc = "Delete current scratch",
    },
    -- Смена filetype у текущего scratch. У snacks ft вшит в имя файла как
    -- расширение (hash.<ft>), но САМ хеш считается от name+count+cwd+branch —
    -- ft в него не входит (см. snacks/scratch.lua M._write_meta). Поэтому
    -- достаточно переименовать оба файла (сам + .meta) и поправить "ft" в meta;
    -- содержимое и «слот» scratch сохраняются.
    {
      "<leader>zc",
      function()
        local file = vim.api.nvim_buf_get_name(0)
        if not file:match("/scratch/") then
          vim.notify("Это не scratch-буфер", vim.log.levels.WARN)
          return
        end
        vim.ui.input({ prompt = "Новый filetype: ", default = vim.bo.filetype }, function(newft)
          if not newft or newft == "" or newft == vim.bo.filetype then
            return
          end
          -- hash.<ft> → hash.<newft> (расширение меняем, хеш остаётся)
          local newfile = file:gsub("%.[^.]+$", "." .. newft)
          -- 1) meta: читаем, меняем ft, пишем под новым именем, старую удаляем
          local meta = vim.fn.readfile(file .. ".meta")
          local ok, decoded = pcall(vim.json.decode, table.concat(meta, "\n"))
          if ok and type(decoded) == "table" then
            decoded.ft = newft
            vim.fn.writefile(vim.split(vim.json.encode(decoded), "\n"), newfile .. ".meta")
          else
            vim.fn.rename(file .. ".meta", newfile .. ".meta")
          end
          vim.fn.delete(file .. ".meta")
          -- 2) содержимое: переносим на диске и закрываем старый буфер
          vim.fn.rename(file, newfile)
          vim.cmd("bdelete!")
          -- 3) переоткрываем scratch — snacks подхватит новый ft из .meta
          Snacks.scratch.open({ file = newfile, ft = newft })
          vim.notify("Scratch ft → " .. newft, vim.log.levels.INFO)
        end)
      end,
      desc = "Change current scratch filetype",
    },
    -- Ctrl+/ шлётся терминалом по-разному: 0x1F=<C-_> в tmux/iTerm2/VSCode
    -- по умолчанию, <C-/> с kitty/CSI-u протоколом — вешаем оба на одно и
    -- то же (та же логика, что раньше в toggleterm.lua).
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
    {
      "<c-_>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
  },
}
