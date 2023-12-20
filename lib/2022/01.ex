defmodule Y2022.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/1
  https://adventofcode.com/2022/day/1/input
  """

  def input, do: Path.join(["input", "2022", "01.txt"]) |> File.read!()

  def sample do
    """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      24000

      iex> input() |> part_1()
      70369
  """
  def part_1(input) do
    sum_top(input, 1)
  end

  defp sum_top(input, top) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn elf ->
      elf
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
    |> Enum.sort(:desc)
    |> Enum.take(top)
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      45000

      iex> input() |> part_2()
      203002
  """
  def part_2(input) do
    sum_top(input, 3)
  end
end
