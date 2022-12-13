import AdventOfCode

solution 2022, 12 do
  @moduledoc """
  https://adventofcode.com/2022/day/12
  https://adventofcode.com/2022/day/12/input
  """

  def sample do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      31

      iex> input() |> part_1()
      484
  """
  def part_1(input) do
    {grid, start_pos, end_pos} = parse_grid(input)

    grid
    |> generate_distances()
    |> Dijkstra.graph(start_pos)
    |> Map.get(end_pos)
  end

  defp parse_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, nil, nil}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x}, {map, s, e} ->
        {cell, s, e} =
          case {cell, s, e} do
            {"S", _, e} -> {char_to_value("a"), {x, y}, e}
            {"E", s, _} -> {char_to_value("z"), s, {x, y}}
            {char, s, e} -> {char_to_value(char), s, e}
          end

        {Map.put(map, {x, y}, cell), s, e}
      end)
    end)
  end

  defp char_to_value(char), do: char |> String.to_charlist() |> hd() |> Kernel.-(97)

  defp generate_distances(grid) do
    grid
    |> Enum.into(%{}, fn {from, value} ->
      from
      |> neighbors()
      |> Enum.filter(&Map.has_key?(grid, &1))
      |> Enum.into(%{}, fn neighbor ->
        neighbor_cost =
          case Map.get(grid, neighbor) do
            v when v > value + 1 -> :infinity
            _v -> 1
          end

        {neighbor, neighbor_cost}
      end)
      |> then(&{from, &1})
    end)
  end

  defp neighbors({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  @doc ~S"""
      iex> sample() |> part_2()
      29

      iex> input() |> part_2()
      478
  """
  def part_2(input) do
    {grid, _, end_pos} = parse_grid(input)
    graph = generate_distances_backwards(grid)

    distances = Dijkstra.graph(graph, end_pos)

    grid
    |> Map.keys()
    |> Enum.filter(&(Map.get(grid, &1) == 0))
    |> Enum.map(&Map.get(distances, &1))
    |> Enum.min()
  end

  defp generate_distances_backwards(grid) do
    grid
    |> Enum.into(%{}, fn {from, value} ->
      from
      |> neighbors()
      |> Enum.filter(&Map.has_key?(grid, &1))
      |> Enum.into(%{}, fn neighbor ->
        neighbor_cost =
          case Map.get(grid, neighbor) do
            v when v < value - 1 -> :infinity
            _v -> 1
          end

        {neighbor, neighbor_cost}
      end)
      |> then(&{from, &1})
    end)
  end
end
