if vim.fn.has("nvim-0.8") == 0 then
  return
end

if vim.g.loaded_neo_zoom ~= nil then
  return
end

require('neo-zoom')

vim.g.loaded_neo_zoom = 1
