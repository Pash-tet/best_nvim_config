return {
  "keaising/im-select.nvim",
  event = "VeryLazy",
  opts = {
    -- Поставлен через `brew install daipeihust/tap/im-select` — НЕ macism
    -- (дефолт плагина на macOS), иначе setup() не найдёт бинарник и молча
    -- откажется вешать автокоманды (см. `is executable` проверку в исходнике).
    default_command = "im-select",
    -- Раскладка, на которую переключаемся при выходе из "режима ввода текста"
    -- (см. events ниже) — под нашу физическую клавиатуру это ABC/US.
    default_im_select = "com.apple.keylayout.ABC",
    -- InsertLeave/CmdlineLeave — дефолт плагина. TermLeave добавлен вручную:
    -- у claudecode.nvim терминал настоящий Neovim-терминал (buftype=terminal
    -- через snacks.nvim), а Terminal-mode — ОТДЕЛЬНЫЙ режим 't' со своими
    -- событиями TermEnter/TermLeave, plugin по умолчанию их не слушает.
    set_default_events = { "InsertLeave", "CmdlineLeave", "TermLeave" },
    -- InsertEnter — дефолт. TermEnter — чтобы при фокусе на терминал с
    -- claudecode обратно включалась раскладка, которая была активна ДО
    -- последнего переключения на default_im_select (обычно русская).
    set_previous_events = { "InsertEnter", "TermEnter" },
  },
}
