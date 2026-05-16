require("kulala").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(ev)
    local map = function(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true })
    end
    map("<LocalLeader>rs", "<cmd>lua require('kulala').run()<CR>")
    map("<LocalLeader>ra", "<cmd>lua require('kulala').run_all()<CR>")
    map("<LocalLeader>rt", "<cmd>lua require('kulala').toggle_view()<CR>")
    map("<LocalLeader>rc", "<cmd>lua require('kulala').copy()<CR>")
    map("]r", "<cmd>lua require('kulala').jump_next()<CR>")
    map("[r", "<cmd>lua require('kulala').jump_prev()<CR>")
  end,
})
