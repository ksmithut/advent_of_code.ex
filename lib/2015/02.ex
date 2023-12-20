defmodule Y2015.D02 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/2
  https://adventofcode.com/2015/day/2/input
  """

  def input, do: Path.join(["input", "2015", "02.txt"]) |> File.read!()

  @doc ~S"""
      iex> "2x3x4" |> part_1()
      58

      iex> "1x1x10" |> part_1()
      43

      iex> input() |> part_1()
      1606483
  """
  def part_1(input) do
    input
    |> parse()
    |> Enum.map(&wrapping_paper/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split()
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  defp wrapping_paper([l, w, h]) do
    areas = [l * w, l * h, w * h]
    Enum.sum(areas) * 2 + Enum.min(areas)
  end

  @doc ~S"""
      iex> "2x3x4" |> part_2()
      34

      iex> "1x1x10" |> part_2()
      14

      iex> input() |> part_2()
      3842356
  """
  def part_2(input) do
    input
    |> parse()
    |> Enum.map(&ribbon/1)
    |> Enum.sum()
  end

  defp ribbon(sides) do
    [a, b, _c] = Enum.sort(sides, :asc)
    (a + b) * 2 + Enum.product(sides)
  end
end
