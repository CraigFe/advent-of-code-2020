function run (turns)
  -- Read initial table
  i = 1; turnspoken = {}
  for v in string.gmatch(io.lines("input.txt")(), "([0-9]+),?") do
    v = tonumber(v)
    turnspoken[v] = i; i = i + 1; last = v
  end
  turnspoken[last] = nil

  -- Compute subsequent turns
  for i = i,turns do
    tmp = turnspoken[last]
    turnspoken[last] = i - 1
    last = (tmp == nil) and 0 or i - tmp - 1
  end
  return last
end

print(run(2020))
print(run(30000000))

