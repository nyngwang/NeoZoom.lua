if vim.fn.has("nvim-0.5") == 0 then
  return
end

if vim.g.loaded_neozoom_nvim ~= nil then
  return
end

require('neo-zoom')

vim.g.loaded_neozoom_nvim = 1
