defmodule Y2023.D13 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/13
  https://adventofcode.com/2023/day/13/input
  """

  def input, do: Path.join(["input", "2023", "13.txt"]) |> File.read!()

  def sample do
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
  end

  @doc ~S"""
      iex> sample() |> part_1()
      405

      iex> input() |> part_1()
      35360
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.map(&find_mirror/1)
    |> score()
  end

  defp find_mirror(grid, compare \\ fn a, b -> a == b end)

  defp find_mirror(grid, compare) when is_binary(grid) do
    rows = grid |> String.split("\n", trim: true)
    columns = rows_to_columns(rows)

    with {:hori, nil} <- {:hori, find_mirror(rows, compare)},
         {:vert, nil} <- {:vert, find_mirror(columns, compare)} do
      0
    end
  end

  defp find_mirror(lines, compare) when is_list(lines) do
    1..(length(lines) - 1)
    |> Enum.find(fn mirror_index ->
      {top, bottom} = Enum.split(lines, mirror_index)
      min_length = min(length(top), length(bottom))
      top = Enum.reverse(top)
      [top, bottom] = [top, bottom] |> Enum.map(&(&1 |> Enum.take(min_length) |> Enum.join("\n")))
      compare.(top, bottom)
    end)
  end

  defp rows_to_columns(rows) do
    rows
    |> Stream.map(&String.graphemes/1)
    |> Stream.zip()
    |> Enum.map(&(&1 |> Tuple.to_list() |> Enum.join()))
  end

  defp score({:vert, num}), do: num
  defp score({:hori, num}), do: num * 100
  defp score(scores), do: scores |> Stream.map(&score/1) |> Enum.sum()

  @doc ~S"""
      iex> sample() |> part_2()
      400

      iex> input() |> part_2()
      36755
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Stream.map(&find_mirror(&1, fn a, b -> string_diff_count(a, b) == 1 end))
    |> score()
  end

  defp string_diff_count(a, b) do
    [a, b]
    |> Stream.map(&String.graphemes/1)
    |> Stream.zip()
    |> Enum.count(fn {a, b} -> a != b end)
  end
end
