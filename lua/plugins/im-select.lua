return {
  "keaising/im-select.nvim",
  event = "VeryLazy",
  -- im-select меняет раскладку ГЛОБАЛЬНО для macOS, поэтому любой "не наш"
  -- инстанс nvim (скриптовый/тестовый: tmux-тесты Claude, git-хуки и т.п.)
  -- дёргал бы раскладку, пока фокус в другом приложении. Такие запуски должны
  -- отключать плагин флагом: nvim --cmd "lua vim.g.im_select_disable = true"
  cond = function()
    return not vim.g.im_select_disable
  end,
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
    -- Пусто СОЗНАТЕЛЬНО (дефолт плагина — {"InsertEnter"}): нам нужно только
    -- одно направление — при выходе из insert/terminal вернуть английскую,
    -- а при входе НЕ восстанавливать «предыдущую» (обычно русскую) раскладку:
    -- код чаще пишется на английском, и автовозврат русской только мешал.
    set_previous_events = {},
  },
  config = function(_, opts)
    require("im_select").setup(opts)

    -- Гейт по фокусу: пока терминал с nvim НЕ в фокусе, плагин не должен
    -- трогать раскладку (иначе события, прилетевшие в расфокусированный nvim,
    -- переключают язык, пока печатаешь в другом приложении). Свои автокоманды
    -- плагин держит в augroup "im-select" и колбэки наружу не экспортирует,
    -- поэтому гейтим на уровне augroup: FocusLost — вычищаем его автокоманды,
    -- FocusGained — пересоздаём повторным setup() (он делает clear=true, так
    -- что дублей не будет). Требует focus reporting от терминала (iTerm2:
    -- Profiles → Terminal → Report focus changed; в tmux: set -g focus-events on).
    local group = vim.api.nvim_create_augroup("im-select-focus-guard", { clear = true })
    vim.api.nvim_create_autocmd("FocusLost", {
      group = group,
      callback = function()
        vim.api.nvim_clear_autocmds({ group = "im-select" })
      end,
    })
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        require("im_select").setup(opts)
      end,
    })
  end,
}
