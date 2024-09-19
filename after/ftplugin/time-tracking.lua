local bufno = vim.api.nvim_get_current_buf()
vim.keymap.set({'i', 'n'}, '<S-Up>',   '<Plug>(TimeTrackingInc)',   {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<S-Down>', '<Plug>(TimeTrackingDec)',   {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<C-s>',    '<Plug>(TimeTrackingDone)',  {buffer = bufno})
vim.keymap.set('n', '<Leader>yr',      '<Plug>(TimeTrackingClone)', {buffer = bufno})

vim.opt_local.foldmethod = 'indent'
vim.opt_local.shiftwidth = 2
