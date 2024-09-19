vim.cmd.syntax('case match')
vim.cmd.syntax('match EntryHeader "^  [0-9]\\{2\\}:[0-9]\\{2\\}\\( \\+[A-Z]\\{2\\}\\>\\)\\?" contains=Timestamp,Project')
vim.cmd.syntax('match Timestamp "^  [0-9]\\{2\\}:[0-9]\\{2\\}" contained')
vim.cmd.syntax('match Project "\\<[A-Z]\\{2\\}\\>" contained')

vim.cmd.highlight('Timestamp ctermfg=LightGreen guifg=LightGreen')
vim.cmd.highlight('Project ctermfg=Cyan guifg=Cyan')
