local bufno = vim.api.nvim_get_current_buf()
vim.keymap.set({'i', 'n'}, '<S-Up>',   '<Plug>(TimeTrackingInc)',  {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<S-Down>', '<Plug>(TimeTrackingDec)',  {buffer = bufno})
vim.keymap.set({'i', 'n'}, '<C-s>',    '<Plug>(TimeTrackingDone)', {buffer = bufno})
