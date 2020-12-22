import DSP
file = "input.txt"

slice = falses(countlines(file), length(readline(file)))
for (i, line) in enumerate(readlines(file))
  parse(x) = (x == '#') ? 1 : (x == '.') ? 0 : error("Invalid: $x")
  slice[i,:] = parse.(collect(line))
end

ncycles = 6

transition(current, neighbours) =
  (current) ? (neighbours == 2 || neighbours == 3) : (neighbours == 3)

function run(dim)

  # Create cube containing the initial slice + `ncycles` of padding in each
  # direction for future expansion
  cube = falses(ntuple((d -> 2 * ncycles + ((d <= 2) ? size(slice, d) : 1)), dim))
  for j in 1:size(slice,2)
    for i in 1:size(slice,1)
      index = CartesianIndex(ntuple((d -> ncycles + ((d == 1) ? i : (d == 2) ? j : 1)), dim))
      cube[index] = slice[i, j]
    end
  end

  # Adjacency matrix: each cell is adjacent to its immediate neighbours in each
  # dimension (but not to itself)
  adj = trues(ntuple(_ -> 3, dim))
  adj[CartesianIndex(ntuple(_ -> 2, dim))] = false
  cube_cart = CartesianIndices(cube)

  for n in 1:ncycles
    # Get neighbour count for entire space by convolving with adjacency matrix
    conv = DSP.conv(cube,adj)
    neighbours(i) = conv[cube_cart[i] + CartesianIndex(ntuple(_ -> 1, dim))]

    for i in eachindex(cube); cube[i] = transition(cube[i], neighbours(i)); end
  end

  reduce(+, cube)
end

println("Part 1: ", run(3))
println("Part 2: ", run(4))
