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

local save_and_maybe_close = function()
  if vim.api.nvim_get_mode()["mode"] ~= 'n' then
    vim.cmd.stopinsert()
  end
  vim.cmd.update()
  if vim.api.nvim_win_get_config(0).relative == 'editor' then
    vim.cmd.close()
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
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingDone)', save_and_maybe_close)
vim.keymap.set({'i', 'n'}, '<Plug>(TimeTrackingClone)', clone_time_tracking_entry)

-- Worktime
local Time = {}
Time.__index = Time

function Time:new(hour, minute)
    local obj = setmetatable({}, self)
    obj.hour = hour % 24 + math.floor(minute / 60)
    obj.minute = minute % 60
    return obj
end

function Time:__sub(other)
    local result = Time:new(self.hour - other.hour, self.minute - other.minute)
    while result.minute < 0 do
        result.hour = result.hour - 1
        result.minute = result.minute + 60
    end
    return result
end

function Time:__add(other)
    local result = Time:new(self.hour + other.hour, self.minute + other.minute)
    while result.minute >= 60 do
        result.hour = result.hour + 1
        result.minute = result.minute - 60
    end
    return result
end

function Time:to_minutes()
    return self.hour * 60 + self.minute
end

function Time:__tostring()
    return string.format("%d:%02d", self.hour, self.minute)
end

local Period = {}
Period.__index = Period

function Period:new(start_time, end_time)
    local obj = setmetatable({}, self)
    obj.start_time = start_time
    obj.end_time = end_time
    return obj
end

function Period:duration()
    return self.end_time - self.start_time
end

function Period:__tostring()
    return string.format("%s-%s", self.start_time, self.end_time)
end

local function parse_periods(s)
    local finditer = string.gmatch(s, "(%d+):(%d+)%s*-%s*(%d+):(%d+)")
    local periods = {}
    for hour1, minute1, hour2, minute2 in finditer do
        table.insert(periods, Period:new(Time:new(tonumber(hour1), tonumber(minute1)), Time:new(tonumber(hour2), tonumber(minute2))))
    end
    return periods
end

local function sum_of(periods)
    local sum = Time:new(0, 0)
    for _, p in ipairs(periods) do
        sum = sum + p:duration()
    end
    return sum
end

local function time_between(periods)
    local pause = Time:new(0, 0)
    local previous_end_time = periods[1].start_time
    for _, p in ipairs(periods) do
        pause = pause + (p.start_time - previous_end_time)
        previous_end_time = p.end_time
    end
    return pause
end

local swm_start = Time:new(6, 30)

local function swm_end(work_time)
    local pause = Time:new(0, 0)
    local work_minutes = work_time:to_minutes()
    if work_minutes > 9 * 60 then
        pause = Time:new(0, 45)
    elseif work_minutes > 6 * 60 then
        pause = Time:new(0, 30)
    end
    return swm_start + work_time + pause
end

local function worktime()
  vim.ui.input({ prompt = 'Times: ' }, function(input)
    local periods = parse_periods(input)
    local work = sum_of(periods)
    local pause = time_between(periods)
    local swm_end = swm_end(work)
    
    vim.api.nvim_echo({{string.format("Work: %s, Pause: %s, SWM: %s - %s", work, pause, swm_start, swm_end)}}, true, {})
  end)
end
vim.keymap.set('n', '<Leader>yw', worktime)
