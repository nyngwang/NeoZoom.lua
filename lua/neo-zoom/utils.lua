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


return M
