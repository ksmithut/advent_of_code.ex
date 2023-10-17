import AdventOfCode

solution 2022, 18 do
  @moduledoc """
  https://adventofcode.com/2022/day/18
  https://adventofcode.com/2022/day/18/input
  """

  def sample do
    """
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      64

      iex> "1,1,1\n2,1,1" |> part_1()
      10

      iex> input() |> part_1()
      3374
  """
  def part_1(input) do
    cubes = parse_input(input)
    grid = MapSet.new(cubes)

    cubes
    |> Enum.map(fn cube ->
      cube
      |> neighbors()
      |> Enum.reject(&MapSet.member?(grid, &1))
      |> length()
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp neighbors({x, y, z}) do
    [
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x, y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ]
  end

  @doc ~S"""
      iex> sample() |> part_2()
      58

      iex> input() |> part_2()
      2010
  """
  def part_2(input) do
    cubes = parse_input(input)
    bits = Enum.into(cubes, %{}, &{&1, true})
    {min_x, _} = x_range = cubes |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, _} = y_range = cubes |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    {min_z, _} = z_range = cubes |> Enum.map(&elem(&1, 2)) |> Enum.min_max()
    fill(bits, [{min_x - 1, min_y - 1, min_z - 1}], {x_range, y_range, z_range})
  end

  defp fill(bits, queue, ranges, visited \\ %{}, total \\ 0)
  defp fill(_bits, [], _ranges, _visited, total), do: total

  defp fill(bits, [item | queue], ranges, visited, total) when is_map_key(bits, item),
    do: fill(bits, queue, ranges, visited, total)

  defp fill(bits, [item | queue], ranges, visited, total) when is_map_key(visited, item),
    do: fill(bits, queue, ranges, visited, total)

  defp fill(bits, [{x, _, _} | queue], {{min, max}, _, _} = ranges, visited, total)
       when x < min - 1 or x > max + 1,
       do: fill(bits, queue, ranges, visited, total)

  defp fill(bits, [{_, y, _} | queue], {_, {min, max}, _} = ranges, visited, total)
       when y < min - 1 or y > max + 1,
       do: fill(bits, queue, ranges, visited, total)

  defp fill(bits, [{_, _, z} | queue], {_, _, {min, max}} = ranges, visited, total)
       when z < min - 1 or z > max + 1,
       do: fill(bits, queue, ranges, visited, total)

  defp fill(bits, [item | queue], ranges, visited, total) do
    neighbors = neighbors(item)
    touching = neighbors |> Enum.count(&is_map_key(bits, &1))
    fill(bits, queue ++ neighbors, ranges, Map.put(visited, item, true), total + touching)
  end
end
