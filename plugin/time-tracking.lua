if vim.g.loaded_time_tracking then
  return
end
vim.g.loaded_time_tracking = true

if not vim.g.time_tracking_path then
  vim.g.time_tracking_path = '~/.default.time-tracking'
end

print('Loading time tracking …')

local open_time_tracking = function()
  vim.cmd.edit(vim.g.time_tracking_path)
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

local time_line_pattern = vim.re.compile('%s+{[%d]+}":"{[%d]+}%s.*')
local time_pattern = vim.re.compile('{[%d]+}":"{[%d]+}')

local get_time = function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], true)[1]
  return vim.re.match(line, time_line_pattern)
end

local replace_time = function(hour, minute)
  local time_string = string.format('%02d:%02d', hour, minute)
  local view = vim.fn.winsaveview()
  vim.cmd('keeppatterns s/\\d\\+:\\d\\+/' .. time_string .. '/')
  vim.fn.winrestview(view)
end

local time_inc = function()
  local hour, minute = get_time()
  if hour then
    minute = minute + 1
    if minute >= 60 then
      hour = hour + 1
      minute = 0
      if hour >= 24 then
        hour = 0
      end
    end
    replace_time(hour, minute)
  end
end

local time_dec = function()
  local hour, minute = get_time()
  if hour then
    minute = minute - 1
    if minute < 0 then
      hour = hour - 1
      minute = 59
      if hour < 0 then
        hour = 23
      end
    end
    replace_time(hour, minute)
  end
end

vim.keymap.set('n', '<Leader>yl', add_time_tracking_entry)
vim.keymap.set('n', '<Leader>yL', edit_time_tracking_entry)
vim.keymap.set({'i', 'n'}, '<S-Up>', time_inc)
vim.keymap.set({'i', 'n'}, '<S-Down>', time_dec)
