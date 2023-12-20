defmodule Y2022.D08 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/8
  https://adventofcode.com/2022/day/8/input
  """

  def input, do: Path.join(["input", "2022", "08.txt"]) |> File.read!()

  def sample do
    """
    30373
    25512
    65332
    33549
    35390
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      21

      iex> input() |> part_1()
      1823
  """
  def part_1(input) do
    input
    |> parse_input()
    |> count_visible()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Stream.map(fn {tree, x} -> {{x, y}, tree} end)
    end)
    |> Map.new()
  end

  defp grid_ranges(grid) do
    keys = Map.keys(grid)
    x_range = keys |> Stream.map(&elem(&1, 0)) |> Enum.min_max()
    y_range = keys |> Stream.map(&elem(&1, 1)) |> Enum.min_max()
    {x_range, y_range}
  end

  defp count_visible(grid) do
    {x_range, y_range} = grid_ranges(grid)
    Enum.count(grid, &visible_from_outside?(grid, x_range, y_range, &1))
  end

  defp visible_from_outside?(_grid, {min_x, _max_x}, _y_range, {{min_x, _y}, _tree}), do: true
  defp visible_from_outside?(_grid, {_min_x, max_x}, _y_range, {{max_x, _y}, _tree}), do: true
  defp visible_from_outside?(_grid, _x_range, {min_y, _max_y}, {{_x, min_y}, _tree}), do: true
  defp visible_from_outside?(_grid, _x_range, {_min_y, max_y}, {{_x, max_y}, _tree}), do: true

  defp visible_from_outside?(grid, {min_x, max_x}, {min_y, max_y}, {{x, y}, tree}) do
    cond do
      Enum.all?(min_x..(x - 1), &(grid[{&1, y}] < tree)) -> true
      Enum.all?((x + 1)..max_x, &(grid[{&1, y}] < tree)) -> true
      Enum.all?(min_y..(y - 1), &(grid[{x, &1}] < tree)) -> true
      Enum.all?((y + 1)..max_y, &(grid[{x, &1}] < tree)) -> true
      true -> false
    end
  end

  @doc ~S"""
      iex> sample() |> part_2()
      8

      iex> input() |> part_2()
      211680
  """
  def part_2(input) do
    input
    |> parse_input()
    |> best_scenic_score()
  end

  defp best_scenic_score(grid) do
    {x_range, y_range} = grid_ranges(grid)

    grid
    |> Stream.map(&scenic_score(grid, x_range, y_range, &1))
    |> Enum.max()
  end

  defp scenic_score(_grid, {min_x, _max_x}, _y_range, {{min_x, _y}, _tree}), do: 0
  defp scenic_score(_grid, {_min_x, max_x}, _y_range, {{max_x, _y}, _tree}), do: 0
  defp scenic_score(_grid, _x_range, {min_y, _max_y}, {{_x, min_y}, _tree}), do: 0
  defp scenic_score(_grid, _x_range, {_min_y, max_y}, {{_x, max_y}, _tree}), do: 0

  defp scenic_score(grid, {min_x, max_x}, {min_y, max_y}, {{x, y}, tree}) do
    [
      count_until((x - 1)..min_x, &(grid[{&1, y}] < tree)),
      count_until((x + 1)..max_x, &(grid[{&1, y}] < tree)),
      count_until((y - 1)..min_y, &(grid[{x, &1}] < tree)),
      count_until((y + 1)..max_y, &(grid[{x, &1}] < tree))
    ]
    |> Enum.product()
  end

  defp count_until(enum, condition) do
    enum
    |> Enum.reduce_while({0, true}, fn
      _value, {count, false} -> {:halt, {count, false}}
      value, {count, true} -> {:cont, {count + 1, condition.(value)}}
    end)
    |> elem(0)
  end
end
