defmodule Y2015.D03 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/4
  https://adventofcode.com/2015/day/4/input
  """

  def input, do: Path.join(["input", "2015", "03.txt"]) |> File.read!()

  @initial_pos {0, 0}

  @doc ~S"""
      iex> ">" |> part_1()
      2

      iex> "^>v<" |> part_1()
      4

      iex> "^v^v^v^v^v" |> part_1()
      2

      iex> input() |> part_1()
      2565
  """
  def part_1(input, num_santas \\ 1) do
    santas = repeat(@initial_pos, num_santas)
    visited = MapSet.new([@initial_pos])

    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce({santas, visited}, fn dir, {[current | others], visited} ->
      current = move(current, dir)
      {others ++ [current], MapSet.put(visited, current)}
    end)
    |> elem(1)
    |> MapSet.size()
  end

  defp repeat(item, amount), do: Stream.cycle([item]) |> Enum.take(amount)

  defp move({x, y}, "^"), do: {x, y - 1}
  defp move({x, y}, ">"), do: {x + 1, y}
  defp move({x, y}, "v"), do: {x, y + 1}
  defp move({x, y}, "<"), do: {x - 1, y}

  @doc ~S"""
      iex> "^v" |> part_2()
      3

      iex> "^>v<" |> part_2()
      3

      iex> "^v^v^v^v^v" |> part_2()
      11

      iex> input() |> part_2()
      2639
  """
  def part_2(input) do
    part_1(input, 2)
  end
end
