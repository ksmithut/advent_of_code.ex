defmodule Y2019.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2019/day/1
  https://adventofcode.com/2019/day/1/input
  """

  def input, do: Path.join(["input", "2019", "01.txt"]) |> File.read!()

  @doc ~S"""
      iex> "12" |> part_1()
      2

      iex> "14" |> part_1()
      2

      iex> "1969" |> part_1()
      654

      iex> "100756" |> part_1()
      33583

      iex> input() |> part_1()
      3406342
  """
  def part_1(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&fuel_required/1)
    |> Enum.sum()
  end

  defp fuel_required(mass), do: div(mass, 3) - 2

  @doc ~S"""
      iex> "14" |> part_2()
      2

      iex> "1969" |> part_2()
      966

      iex> "100756" |> part_2()
      50346

      iex> input() |> part_2()
      5106629
  """
  def part_2(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&all_fuel_required/1)
    |> Enum.sum()
  end

  defp all_fuel_required(mass) do
    mass
    |> fuel_required()
    |> Stream.iterate(&fuel_required/1)
    |> Enum.reduce_while(0, fn
      mass, acc when mass > 0 -> {:cont, acc + mass}
      _mass, acc -> {:halt, acc}
    end)
  end
end
