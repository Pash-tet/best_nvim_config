return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} }, -- сам менеджер: качает бинарники серверов
      "neovim/nvim-lspconfig",               -- готовые конфиги (cmd, root_markers) для сотен серверов
    },
    opts = {
      -- mason-lspconfig сам скачает эти сервера через mason И сам вызовет
      -- vim.lsp.enable() для каждого — вручную .setup{} по-старому не нужен
      ensure_installed = {
        "lua_ls",     -- Lua (наш собственный конфиг)
        "ruby_lsp",   -- Ruby
        "pyright",    -- Python
        "ts_ls",      -- JS/TypeScript
        "bashls",     -- Bash
      },
    },
  },

  -- Раньше здесь был костыль vim.lsp.config("lua_ls", {settings={Lua={diagnostics={globals={"vim"}}}}}),
  -- который просто ЗАГЛУШАЛ предупреждение "undefined global vim".
  -- lazydev.nvim (см. lua/plugins/lazydev.lua) решает это правильно —
  -- подключает lua_ls к настоящим типам vim.* API, а не просто прячет warning.

  {
    "neovim/nvim-lspconfig",
    config = function()
      -- '*' — специальный конфиг, применяется КО ВСЕМ серверам сразу.
      -- Без этого LSP-серверы не будут знать, что клиент (blink.cmp) умеет
      -- принимать более широкие данные (например, сниппеты в автодополнении).
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- LSP-кеймапы в стиле LazyVim. Вешаем ПО СОБЫТИЮ LspAttach (буфер-локально
      -- на файлы, где реально подключился сервер), а не глобально.
      -- ВАЖНО про совместимость со встроенными кеймапами nvim: мы СОЗНАТЕЛЬНО НЕ
      -- маппим одиночный "gr" (references). У Neovim 0.11+ встроены gr-префиксные
      -- кеймапы: grr (references), grn (rename), gra (code action), gri
      -- (implementation). Если замапить "gr" целиком — они бы сломались/затупили
      -- (ambiguity с gr-префиксом). Поэтому: goto-definition/impl/type-def
      -- добавляем на СВОБОДНЫЕ клавиши gd/gI/gy (через telescope-пикеры), а
      -- references/rename/code-action остаются на родных grr/grn/gra — они и есть
      -- LazyVim-эквиваленты. Плюс дублируем rename/action под <leader>c-группу.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_lazyvim_keymaps", { clear = true }),
        callback = function(ev)
          local tb = require("telescope.builtin")
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd", tb.lsp_definitions, "Goto Definition")
          map("gI", tb.lsp_implementations, "Goto Implementation")
          map("gy", tb.lsp_type_definitions, "Goto Type Definition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cl", function()
            vim.cmd("checkhealth vim.lsp")
          end, "LSP info")
        end,
      })
    end,
  },
}
