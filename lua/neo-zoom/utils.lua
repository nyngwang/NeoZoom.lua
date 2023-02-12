local M = {}


function M.table_contains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end


function M.table_add_values(table, values)
  for _, v in pairs(values) do
    table[#table + 1] = v
  end

  return table
end


function M.run_callbacks(table)
  if type(table) == 'table' then
    for _, cb in pairs(table) do
      if type(cb) == 'function' then cb() end
    end
  end
end


function M.ratio_to_integer(value, base)
  return value > 1 and value or math.ceil(base * value + 0.5)
end


return M
