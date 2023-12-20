defmodule Y2022.D14 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/14
  https://adventofcode.com/2022/day/14/input
  """

  def input, do: Path.join(["input", "2022", "14.txt"]) |> File.read!()

  def sample do
    """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      24

      iex> input() |> part_1()
      817
  """
  def part_1(input) do
    grid = create_grid(input)
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    continuously_drop_sand({:settled, grid}, max_y) |> count_sand()
  end

  defp create_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line_def, set ->
      line_def
      |> String.split(" -> ")
      |> Enum.map(fn point ->
        point
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [x, y] -> {x, y} end)
      end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(set, fn [{x1, y1}, {x2, y2}], set ->
        for x <- x1..x2, y <- y1..y2, into: set, do: {{x, y}, :wall}
      end)
    end)
  end

  defp continuously_drop_sand({:settled, grid}, max_y) do
    grid |> drop_sand(max_y, {500, 0}) |> continuously_drop_sand(max_y)
  end

  defp continuously_drop_sand({:endless, grid}, _max_y), do: grid
  defp continuously_drop_sand({:at_source, grid}, _max_y), do: grid

  defp drop_sand(grid, max_y, source), do: drop_sand(grid, max_y, source, source)
  defp drop_sand(grid, max_y, _source, {_, y}) when y > max_y, do: {:endless, grid}

  defp drop_sand(grid, max_y, source, {x, y}) when not is_map_key(grid, {x, y + 1}) do
    drop_sand(grid, max_y, source, {x, y + 1})
  end

  defp drop_sand(grid, max_y, source, {x, y}) when not is_map_key(grid, {x - 1, y + 1}) do
    drop_sand(grid, max_y, source, {x - 1, y + 1})
  end

  defp drop_sand(grid, max_y, source, {x, y}) when not is_map_key(grid, {x + 1, y + 1}) do
    drop_sand(grid, max_y, source, {x + 1, y + 1})
  end

  defp drop_sand(grid, _max_y, source, source), do: {:at_source, Map.put(grid, source, :sand)}
  defp drop_sand(grid, _max_y, _source, point), do: {:settled, Map.put(grid, point, :sand)}

  defp count_sand(grid), do: Enum.count(grid, &(elem(&1, 1) == :sand))

  @doc ~S"""
      iex> sample() |> part_2()
      93

      iex> input() |> part_2()
      23416
  """
  def part_2(input) do
    grid = create_grid(input)
    keys = grid |> Map.keys()
    max_y = keys |> Enum.map(&elem(&1, 1)) |> Enum.max()
    grid = for x <- (500 - max_y * 2)..(500 + max_y * 2), into: grid, do: {{x, max_y + 2}, :wall}
    continuously_drop_sand({:settled, grid}, max_y + 2) |> count_sand()
  end
end
