local M = {}


function M.table_contains(table, value)
  for _, pattern_v in pairs(table) do
    if value == pattern_v
      or string.match(value, pattern_v)
    then
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


function M.ratio_to_integer(value, base, one_for_full)
  return one_for_full
    and (value > 1 and value or math.floor(base * value))
    or (value >= 1 and value or math.floor(base * value))
end


function M.integer_to_ratio(value, base, one_for_full)
  return one_for_full
    and (value <= 1 and value or (value / base))
    or (value < 1 and value or (value / base))
end


function M.get_side_ratio(value, base)
  return (1 - M.integer_to_ratio(value, base, true)) / 2
end


function M.with_fallback(A, B)
  return A and A or B
end


return M
