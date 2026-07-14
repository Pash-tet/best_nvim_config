-- Точка входа. Nvim при старте ищет именно этот файл в ~/.config/nvim/

-- Leader key нужно задать ДО того, как что-либо ещё загрузится,
-- иначе keymaps, использующие <leader>, зарегистрируются со старым лидером.
vim.g.mapleader = " " -- пробел как leader
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")
require("core.erb_endwise")
require("config.lazy")
