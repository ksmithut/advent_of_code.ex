defmodule Y2023.D18 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/18
  https://adventofcode.com/2023/day/18/input
  """

  def input, do: Path.join(["input", "2023", "18.txt"]) |> File.read!()

  def sample do
    """
    R 6 (#70c710)
    D 5 (#0dc571)
    L 2 (#5713f0)
    D 2 (#d2c081)
    R 2 (#59c680)
    D 2 (#411b91)
    L 5 (#8ceee2)
    U 2 (#caa173)
    L 1 (#1b58a2)
    U 2 (#caa171)
    R 2 (#7807d2)
    U 3 (#a77fa3)
    L 2 (#015232)
    U 2 (#7a21e3)
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      [dir, amount, color] = String.split(line)
      "(#" <> <<a::binary-size(5), d::binary-size(1)>> <> ")" = color
      {{dir, String.to_integer(amount)}, {num_to_dir(d), String.to_integer(a, 16)}}
    end)
  end

  defp num_to_dir("0"), do: "R"
  defp num_to_dir("1"), do: "D"
  defp num_to_dir("2"), do: "L"
  defp num_to_dir("3"), do: "U"

  @doc ~S"""
      iex> sample() |> part_1()
      62

      iex> input() |> part_1()
      52055
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&elem(&1, 0))
    |> find_area()
  end

  defp move("U", {x, y}, n), do: {x, y - n}
  defp move("D", {x, y}, n), do: {x, y + n}
  defp move("L", {x, y}, n), do: {x - n, y}
  defp move("R", {x, y}, n), do: {x + n, y}

  defp find_area(instructions) do
    instructions
    |> Enum.reduce({0, [{0, 0}]}, fn {dir, n}, {perimeter, [pos | _] = list} ->
      {perimeter + n, [move(dir, pos, n) | list]}
    end)
    |> then(fn {perimeter, list} ->
      size = length(list)
      plan = list |> Enum.reverse() |> Stream.with_index() |> Map.new(fn {v, i} -> {i, v} end)
      plan = Map.put(plan, -1, plan[size - 1])

      # https://en.wikipedia.org/wiki/Shoelace_formula
      area =
        0..(size - 1)
        |> Stream.map(fn i ->
          elem(plan[i], 1) * (elem(plan[i - 1], 0) - elem(plan[rem(i + 1, size)], 0))
        end)
        |> Enum.sum()
        |> abs()
        |> div(2)

      area - div(perimeter, 2) + 1 + perimeter
    end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      952408144115

      iex> input() |> part_2()
      67622758357096
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&elem(&1, 1))
    |> find_area()
  end
end
