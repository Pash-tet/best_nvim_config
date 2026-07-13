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
      "slim", -- шаблоны Slim (парсер theoo/tree-sitter-slim из реестра nvim-treesitter)
      "css",  -- нужен nvim-html-css: он парсит стили (inline <style> и внешние
              -- .css) именно treesitter-парсером css; без него класс-комплит не работает
    })

    -- filetype "eruby" (.erb) не совпадает с именем парсера "embedded_template" —
    -- без этой регистрации vim.treesitter.start() не поймёт, какой парсер использовать
    vim.treesitter.language.register("embedded_template", "eruby")

    -- Neovim нативно НЕ определяет .slim как filetype (vim.filetype.match → nil),
    -- поэтому регистрируем сами. Имя парсера "slim" совпадает с filetype "slim",
    -- так что register() тут не нужен — FileType-хук ниже сам вызовет treesitter.start().
    vim.filetype.add({ extension = { slim = "slim" } })

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
