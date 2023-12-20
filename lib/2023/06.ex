defmodule Y2023.D06 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/6
  https://adventofcode.com/2023/day/6/input
  """

  def input, do: Path.join(["input", "2023", "06.txt"]) |> File.read!()

  def sample do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&(&1 |> String.split() |> tl()))
  end

  @doc ~S"""
      iex> sample() |> part_1()
      288

      iex> input() |> part_1()
      138915
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Stream.zip()
    |> Stream.map(&winning_ranges/1)
    |> Enum.product()
  end

  defp winning_ranges({race_length, high_score}) do
    left = Enum.find(1..race_length, &(distance(&1, race_length) > high_score))
    right = Enum.find(race_length..1, &(distance(&1, race_length) > high_score))
    Range.size(left..right)
  end

  defp distance(hold_time, race_length), do: (race_length - hold_time) * hold_time

  @doc ~S"""
      iex> sample() |> part_2()
      71503

      iex> input() |> part_2()
      27340847
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn line -> line |> Enum.join() |> String.to_integer() end)
    |> then(fn [a, b] -> {a, b} end)
    |> winning_ranges()
  end
end
