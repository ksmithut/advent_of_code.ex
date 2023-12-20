defmodule Y2017.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2017/day/1
  https://adventofcode.com/2017/day/1/input
  """

  def input, do: Path.join(["input", "2017", "01.txt"]) |> File.read!()

  @doc ~S"""
      iex> "1122" |> part_1()
      3

      iex> "1111" |> part_1()
      4

      iex> "1234" |> part_1()
      0

      iex> "91212129" |> part_1()
      9

      iex> input() |> part_1()
      1097
  """
  def part_1(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> then(&Enum.chunk_every(&1, 2, 1, Stream.cycle(&1)))
    |> Enum.reduce(0, fn
      [a, a], acc -> acc + a
      _, acc -> acc
    end)
  end

  @doc ~S"""
      iex> "1212" |> part_2()
      6

      iex> "1221" |> part_2()
      0

      iex> "123425" |> part_2()
      4

      iex> "123123" |> part_2()
      12

      iex> "12131415" |> part_2()
      4

      iex> input() |> part_2()
      1188
  """
  def part_2(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> then(&Enum.chunk_every(&1, div(length(&1), 2)))
    |> Enum.zip()
    |> Enum.reduce(0, fn
      {a, a}, acc -> acc + a
      _, acc -> acc
    end)
    |> Kernel.*(2)
  end
end
