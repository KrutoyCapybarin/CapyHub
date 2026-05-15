local io = require("io")
local os = require("os")

if io ~= nil then
  local file = io.open("config.txt", "r")
  if file then
    local content = file:read("*a")
    file:close()
    print(content)
  else
    print("Файл не найден")
  end
else
  print("io недоступен")
end