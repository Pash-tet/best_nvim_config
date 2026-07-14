return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
  cmd = "Neotree",
  -- Конфиг взят из реального extras/editor/neo-tree.lua LazyVim (curl с
  -- raw.githubusercontent.com, не по памяти) и урезан под то, что у нас
  -- реально есть: убрали LazyVim.root() (нет такого хелпера в нашем
  -- конфиге — используем vim.uv.cwd()) и автообновление git_status после
  -- закрытия lazygit-терминала (lazygit не подключён).
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree",
    },
    {
      "<leader>ge",
      function()
        require("neo-tree.command").execute({ source = "git_status", toggle = true })
      end,
      desc = "Git Explorer",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({ source = "buffers", toggle = true })
      end,
      desc = "Buffer Explorer",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- Та же грабля, что раньше решали для netrw: `nvim .` должен показать
    -- дерево, а не голый netrw, но плагин лениво грузится по cmd="Neotree" —
    -- при `nvim .` он ещё не загружен в момент открытия директории. Хук:
    -- как только видим, что открываемый буфер — директория, require()'им
    -- neo-tree ПОСТФАКТУМ, но до отрисовки netrw (штатный фикс из LazyVim).
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("neo_tree_start_directory", { clear = true }),
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then
          return
        end
        local stats = vim.uv.fs_stat(vim.fn.argv(0))
        if stats and stats.type == "directory" then
          require("neo-tree")
        end
      end,
    })
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = { "terminal", "qf" },
    close_if_last_window = true, -- дерево закрывается, а не растягивается на весь экран
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          -- Grep по директории под курсором (если это файл — берём его
          -- родительскую директорию). Живёт только в filesystem-источнике:
          -- "gr" в git_status уже занято под git_revert_file, там это
          -- значение сохраняется как есть.
          ["gr"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node.path
              if node.type ~= "directory" then
                path = vim.fn.fnamemodify(path, ":h")
              end
              require("telescope.builtin").live_grep({ search_dirs = { path } })
            end,
            desc = "Grep in this directory",
          },
        },
      },
    },
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["Y"] = {
          function(state)
            vim.fn.setreg("+", state.tree:get_node():get_id(), "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "Open with System Application",
        },
        ["P"] = { "toggle_preview", config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      -- git-статус в дереве: изменённые/новые файлы подсвечиваются и
      -- получают значки прямо в filesystem-источнике (не только в
      -- отдельном git_status-источнике на <leader>ge).
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
    },
    -- Snacks уже стоит (lua/plugins/snacks.lua) и грузится eager (lazy=false,
    -- priority=1000) — Snacks.rename доступен к моменту, когда пользователь
    -- реально переименует/переместит файл в дереве.
    event_handlers = {
      {
        event = "file_moved",
        handler = function(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end,
      },
      {
        event = "file_renamed",
        handler = function(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end,
      },
    },
  },
}
