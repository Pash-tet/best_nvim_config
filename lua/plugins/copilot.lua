return {
  "github/copilot.vim",
  -- НЕ лениво: вся инициализация copilot.vim (copilot#Init + Tab-маппинг)
  -- висит на autocmd VimEnter. При lazy-load на InsertEnter/cmd VimEnter уже
  -- прошёл, Init не вызывается — и подсказки молчат, пока не дёрнешь любую
  -- :Copilot-команду вручную. Сам плагин лёгкий, node поднимается асинхронно.
  lazy = false,
}
