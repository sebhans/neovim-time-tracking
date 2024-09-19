if vim.g.loaded_time_tracking then
  return
end
vim.g.loaded_time_tracking = true

if not vim.g.time_tracking_path then
  vim.g.time_tracking_path = '~/.default.time-tracking'
end

local open_time_tracking = function()
  local dummy = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(dummy, true, {
    relative = 'editor',
    row = vim.o.lines / 2 - 4,
    col = vim.o.columns / 2 - 24,
    width = 50,
    height = 5,
    border = 'rounded',
  })
  vim.cmd.edit(vim.g.time_tracking_path)
  vim.bo.buflisted = false
end

local append_lines = function(lines)
  vim.cmd.normal('G')
  vim.api.nvim_put(lines, 'l', true, true)
end

local add_time_tracking_entry = function()
  open_time_tracking()
  local today = os.date('%A, %d.%m.%Y')
  local dayLine = vim.fn.search(today, 'nw')
  if dayLine == 0 then
    append_lines({'', today})
  end
  local now = os.date('%H:%M')
  append_lines({'  ' .. now .. ' '})
  vim.cmd.normal('$')
  vim.cmd('startinsert!')
end

local edit_time_tracking_entry = function()
  open_time_tracking()
  vim.cmd.normal('G04w')
end

local get_current_line = function()
  local pos = vim.api.nvim_win_get_cursor(0)
  return vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], true)[1]
end

local time_line_pattern = vim.re.compile('%s+{[%d]+}":"{[%d]+}%s.*')
local time_pattern = vim.re.compile('{[%d]+}":"{[%d]+}')

local get_time = function()
  local line = get_current_line()
  return vim.re.match(line, time_line_pattern)
end

local replace_time_string = function(time_string)
  local view = vim.fn.winsaveview()
  vim.cmd('keeppatterns s/\\d\\+:\\d\\+/' .. time_string .. '/')
  vim.fn.winrestview(view)
end

local replace_time = function(hour, minute)
  replace_time_string(string.format('%02d:%02d', hour, minute))
end

local time_inc = function(d)
  local hour, minute = get_time()
  if hour then
    minute = minute + d
    if minute >= 60 then
      hour = hour + 1
      minute = minute - 60
      if hour >= 24 then
        hour = 0
      end
    end
    replace_time(hour, minute)
  end
end

local time_dec = function(d)
  local hour, minute = get_time()
  if hour then
    minute = minute - d
    if minute < 0 then
      hour = hour - 1
      minute = minute + 60
      if hour < 0 then
        hour = 23
      end
    end
    replace_time(hour, minute)
  end
end

local clone_time_tracking_entry = function()
  local entry = get_current_line()
  vim.cmd.normal('G')
  if get_current_line() == '' then
    vim.api.nvim_put({entry}, 'c', true, true)
  else
    vim.api.nvim_put({entry}, 'l', true, true)
  end
  replace_time_string(os.date('%H:%M'))
  vim.cmd.normal('$')
end

local save_and_prev_buffer = function()
  if vim.api.nvim_get_mode()["mode"] ~= 'n' then
    vim.cmd.stopinsert()
  end
  vim.cmd.update()
  if vim.api.nvim_win_get_config(0).relative == 'editor' then
    vim.cmd.close()
  else
    vim.cmd.edit('#')
  end
end

vim.filetype.add({
  extension = {
    ['time-tracking'] = 'time-tracking'
  },
})

local success, wk = pcall(require, 'which-key')
if success then
  wk.add({
    { '<Leader>y', group = "Sebastian's custom commands" },
    { '<Leader>yl', desc = "add time tracking entry" },
    { '<Leader>yL', desc = "edit last time tracking entry" },
  })
end

vim.keymap.set('n', '<Leader>yl', add_time_tracking_entry)
vim.keymap.set('n', '<Leader>yL', edit_time_tracking_entry)

vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingInc1)', function() time_inc(1) end)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingInc15)', function() time_inc(15) end)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingDec1)', function() time_dec(1) end)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingDec15)', function() time_dec(15) end)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingDone)', save_and_prev_buffer)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingClone)', clone_time_tracking_entry)
