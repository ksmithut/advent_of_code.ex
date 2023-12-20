defmodule Y2015.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/1
  https://adventofcode.com/2015/day/1/input
  """

  def input, do: Path.join(["input", "2015", "01.txt"]) |> File.read!()

  @doc ~S"""
      iex> "(())" |> part_1()
      0

      iex> "()()" |> part_1()
      0

      iex> "(((" |> part_1()
      3

      iex> "(()(()(" |> part_1()
      3

      iex> "))(((((" |> part_1()
      3

      iex> "())" |> part_1()
      -1

      iex> "))(" |> part_1()
      -1

      iex> ")))" |> part_1()
      -3

      iex> ")())())" |> part_1()
      -3

      iex> input() |> part_1()
      74
  """
  def part_1(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce(0, fn
      "(", floor -> floor + 1
      ")", floor -> floor - 1
    end)
  end

  @doc ~S"""
      iex> ")" |> part_2()
      1

      iex> "()())" |> part_2()
      5

      iex> input() |> part_2()
      1795
  """
  def part_2(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce_while({0, 0}, fn
      _, {-1, count} -> {:halt, {-1, count}}
      "(", {floor, count} -> {:cont, {floor + 1, count + 1}}
      ")", {floor, count} -> {:cont, {floor - 1, count + 1}}
    end)
    |> elem(1)
  end
end
