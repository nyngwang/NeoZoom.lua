local M = {}


function M.value_in_table(table, value)
  for _, v in ipairs(table) do
    if value == v then
      return true
    end
  end
  return false
end

function M.table_add_values(table, values)
  for _, v in ipairs(values) do
    table[#table + 1] = v
  end
  
  return table
end


function M.add_scrolloff(offset)
  local scrolloff = offset
  local cur_line = vim.fn.line('.')
  vim.cmd('normal! zt')
  if (cur_line > scrolloff) then
    vim.cmd('normal! ' .. scrolloff .. 'k' .. scrolloff .. 'j')
  else
    vim.cmd('normal! ' .. (cur_line-1) .. 'k' .. (cur_line-1) .. 'j')
  end
end


return M
