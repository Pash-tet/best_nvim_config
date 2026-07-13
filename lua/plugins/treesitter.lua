return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,        -- README прямо говорит: этот плагин НЕ поддерживает ленивую загрузку
  build = ":TSUpdate",  -- выполняется после install/update плагина — подтягивает актуальные парсеры
  config = function()
    require("nvim-treesitter").install({
      "lua", "vim", "vimdoc", "query",  -- нужны для конфига самого nvim
      "bash", "markdown", "markdown_inline",
      "python", "javascript", "typescript",
      "ruby",
      "html", "embedded_template", -- embedded_template = грамматика ERB (и EJS)
    })

    -- filetype "eruby" (.erb) не совпадает с именем парсера "embedded_template" —
    -- без этой регистрации vim.treesitter.start() не поймёт, какой парсер использовать
    vim.treesitter.language.register("embedded_template", "eruby")

    -- Новый API (main branch) больше не включает highlight декларативно через setup({highlight=...}).
    -- Вместо этого сам Neovim предоставляет vim.treesitter.start() — вызываем на каждый файл.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      pattern = "*",
      callback = function()
        -- pcall — на случай, если для этого filetype нет установленного парсера
        local ok = pcall(vim.treesitter.start)
        if ok then
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end
      end,
    })
  end,
}
