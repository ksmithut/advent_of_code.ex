defmodule Y2023.D17 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/17
  https://adventofcode.com/2023/day/17/input
  """

  def input, do: Path.join(["input", "2023", "17.txt"]) |> File.read!()

  def sample do
    """
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """
  end

  defp parse_input(input) do
    input
    |> String.split()
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Stream.map(fn {n, x} -> {{x, y}, n} end)
    end)
    |> Map.new()
  end

  @doc ~S"""
      iex> sample() |> part_1()
      102

      iex> input() |> part_1()
      686
  """
  def part_1(input, min_length \\ 1, max_length \\ 3) do
    grid = parse_input(input)
    keys = Map.keys(grid)
    {min_x, max_x} = keys |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = keys |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    x_range = min_x..max_x
    y_range = min_y..max_y
    target = {max_x, max_y}

    {
      [
        {grid[{1, 0}], {1, 0}, {1, 0}, 1},
        {grid[{0, 1}], {0, 1}, {0, 1}, 1}
      ]
      |> Enum.into(Heap.min()),
      MapSet.new()
    }
    |> reduce(fn {queue, seen} ->
      {{w, {x, y} = pos, {dx, dy} = dir, length}, queue} = Heap.split(queue)

      cond do
        {pos, dir, length} in seen ->
          {:cont, {queue, seen}}

        pos == target and length >= min_length ->
          {:halt, w}

        true ->
          queue =
            List.flatten([
              if(length < max_length, do: {{x + dx, y + dy}, dir, length + 1}, else: []),
              if(length >= min_length,
                do: [{{x + dy, y + dx}, {dy, dx}, 1}, {{x - dy, y - dx}, {-dy, -dx}, 1}],
                else: []
              )
            ])
            |> Stream.filter(fn {{x, y} = xy, _, _} ->
              y in y_range && x in x_range && xy not in seen
            end)
            |> Stream.map(fn {pos, dir, length} -> {w + grid[pos], pos, dir, length} end)
            |> Enum.reduce(queue, fn e, q -> Heap.push(q, e) end)

          {:cont, {queue, MapSet.put(seen, {pos, dir, length})}}
      end
    end)
  end

  defp reduce(init, func), do: do_reduce(func.(init), func)
  defp do_reduce({:halt, result}, _), do: result
  defp do_reduce({:cont, value}, func), do: do_reduce(func.(value), func)

  @doc ~S"""
      iex> sample() |> part_2()
      94

      iex> input() |> part_2()
      801
  """
  def part_2(input) do
    part_1(input, 4, 10)
  end
end
