defmodule Y2018.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2018/day/1
  https://adventofcode.com/2018/day/1/input
  """

  def input, do: Path.join(["input", "2018", "01.txt"]) |> File.read!()

  @doc ~S"""
      iex> "+1\n+1\n+1" |> part_1()
      3

      iex> "+1\n+1\n-2" |> part_1()
      0

      iex> "-1\n-2\n-3" |> part_1()
      -6

      iex> input() |> part_1()
      459
  """
  def part_1(input) do
    input
    |> String.split()
    |> Enum.map(&elem(Integer.parse(&1), 0))
    |> Enum.sum()
  end

  @doc ~S"""
      iex> "+1\n-1" |> part_2()
      0

      iex> "+3\n+3\n+4\n-2\n-4" |> part_2()
      10

      iex> "-6\n+3\n+8\n+5\n-6" |> part_2()
      5

      iex> "+7\n+7\n-2\n-7\n-4" |> part_2()
      14

      iex> input() |> part_2()
      65474
  """
  def part_2(input) do
    input
    |> String.split()
    |> Enum.map(&elem(Integer.parse(&1), 0))
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn delta, {freq, visited} ->
      freq = freq + delta

      case MapSet.member?(visited, freq) do
        true -> {:halt, {freq, visited}}
        false -> {:cont, {freq, MapSet.put(visited, freq)}}
      end
    end)
    |> elem(0)
  end
end
