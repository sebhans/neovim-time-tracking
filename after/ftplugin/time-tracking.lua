local bufno = vim.api.nvim_get_current_buf()
vim.keymap.set({'i', 'n'}, '<S-Up>',     '<Plug>(TimeTrackingInc1)',  {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<M-S-Up>',   '<Plug>(TimeTrackingInc15)', {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<S-Down>',   '<Plug>(TimeTrackingDec1)',  {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<M-S-Down>', '<Plug>(TimeTrackingDec15)', {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<C-s>',      '<Plug>(TimeTrackingDone)',  {buffer = bufno})
vim.keymap.set({     'n'}, '<Leader>yr', '<Plug>(TimeTrackingClone)', {buffer = bufno})

vim.opt_local.foldmethod = 'indent'
vim.opt_local.shiftwidth = 2
