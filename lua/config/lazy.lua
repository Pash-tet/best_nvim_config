-- === Bootstrap: если lazy.nvim ещё не скачан на диск — качаем его сами ===
-- stdpath("data") — стандартная папка nvim для ДАННЫХ (не конфига!):
-- на macOS это ~/.local/share/nvim. Именно туда ставятся все плагины.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- fs_stat вернёт nil, если по этому пути ничего нет — значит, lazy.nvim не установлен
-- (vim.uv — новое имя, vim.loop — старое; оба указывают на одно и то же (libuv))
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end

-- Добавляем lazy.nvim в начало runtimepath, чтобы require("lazy") ниже вообще смог его найти
-- (вспоминаем урок про require: без этого lazy.nvim просто не в путях поиска модулей)
vim.opt.rtp:prepend(lazypath)

-- === Настоящая настройка lazy.nvim ===
require("lazy").setup({
  spec = {
    -- import = "plugins" означает: возьми ВСЕ файлы из lua/plugins/*.lua,
    -- каждый должен return {...} — plugin spec (см. урок про модули и require)
    { import = "plugins" },
  },
  checker = { enabled = false }, -- не проверять обновления плагинов автоматически при старте
})
