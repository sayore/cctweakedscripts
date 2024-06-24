local args = {...}

print (shell.getRunningProgram())
-- loop over args and print them
for _, arg in ipairs(args) do
  print(arg)
end
