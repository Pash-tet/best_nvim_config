return {
	"goolord/alpha-nvim",
	event = "VimEnter", -- показать дашборд ДО того, как что-либо ещё займёт экран
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		local dashboard = require("alpha.themes.dashboard")
		local theta = require("alpha.themes.theta")

		-- Свой логотип вместо дефолтного курсивного "alpha" из theta.
		theta.header.val = {
			"                                                               ",
			"▄▄▄    ▄▄▄                   ▄▄▄▄  ▄▄▄▄   ▄▄▄▄▄   ▄▄▄      ▄▄▄ ",
			"████▄  ███                   ▀███  ███▀    ███    ████▄  ▄████ ",
			"███▀██▄███   ▄█▀█▄   ▄███▄    ███  ███     ███    ███▀████▀███ ",
			"███  ▀████   ██▄█▀   ██ ██    ███▄▄███     ███    ███  ▀▀  ███ ",
			"███    ███   ▀█▄▄▄   ▀███▀     ▀████▀     ▄███▄   ███      ███ ",
			"                                                               ",
			"                                                               ",
		}

		-- Recent files по умолчанию скрыты (theta.section_mru рисует их сразу
		-- при открытии дашборда) — показываем список только по нажатию "r",
		-- через :AlphaToggleMru + redraw. До нажатия — просто подсказка на
		-- месте списка, чтобы layout не прыгал по высоте.
		local mru_visible = false

		local section_mru_toggle = {
			type = "group",
			val = function()
				if mru_visible then
					return { theta.section_mru }
				end
				return {
					{
						type = "text",
						val = "Press r for recent files",
						opts = { hl = "Comment", position = "center" },
					},
				}
			end,
		}

		vim.api.nvim_create_user_command("AlphaToggleMru", function()
			mru_visible = not mru_visible
			require("alpha").redraw()
		end, {})

		theta.config.layout[4] = section_mru_toggle

		-- Configuration раньше молча делал :cd в конфиг без видимого эффекта —
		-- открываем его теперь в neo-tree, чтобы кнопка реально что-то показывала.
		-- Текст/иконку берём у оригинальной кнопки theta, чтобы не перепечатывать
		-- nerd-font глиф руками.
		local orig_config_btn = theta.buttons.val[6]
		theta.buttons.val[6] =
			dashboard.button("c", orig_config_btn.val, "<cmd>Neotree dir=" .. vim.fn.stdpath("config") .. "<CR>")

		-- Кнопка "r" — показать/скрыть recent files. Иконку берём с кнопки
		-- "New file" (индекс 3): текст "  New file" -> оставляем тот же глиф.
		local file_icon = theta.buttons.val[3].val:match("^(.-)New file$") or ""
		table.insert(
			theta.buttons.val,
			4,
			dashboard.button("r", file_icon .. "Recent files", "<cmd>AlphaToggleMru<CR>")
		)

		-- Restore Session — перед Quit (последней кнопкой в списке).
		table.insert(
			theta.buttons.val,
			#theta.buttons.val,
			dashboard.button("s", "  Restore Session", "<cmd>lua require('persistence').load()<cr>")
		)

		return theta.config
	end,
	config = function(_, opts)
		require("alpha").setup(opts)
	end,
}
