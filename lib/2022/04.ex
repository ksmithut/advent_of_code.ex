defmodule Y2022.D04 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/4
  https://adventofcode.com/2022/day/4/input
  """

  def input, do: Path.join(["input", "2022", "04.txt"]) |> File.read!()

  def sample do
    """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      2

      iex> input() |> part_1()
      471
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Enum.count(fn {left, right} ->
      MapSet.subset?(left, right) or MapSet.subset?(right, left)
    end)
  end

  defp parse_input(input) do
    input
    |> String.split()
    |> Enum.map(&parse_line/1)
  end

  @doc """
      iex> parse_line("57-93,9-57")
      {MapSet.new(57..93), MaSet.new(9..57)}
  """
  def parse_line(line) do
    line
    |> String.split(",")
    |> Enum.map(fn side ->
      side
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> then(fn [a, b] -> a..b end)
      |> MapSet.new()
    end)
    |> then(fn [left, right] -> {left, right} end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      4

      iex> input() |> part_2()
      888
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Enum.count(fn {left, right} ->
      not MapSet.disjoint?(left, right)
    end)
  end
end
