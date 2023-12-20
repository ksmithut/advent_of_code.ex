defmodule Y2023.D04 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/4
  https://adventofcode.com/2023/day/4/input
  """

  def input, do: Path.join(["input", "2023", "04.txt"]) |> File.read!()

  def sample do
    """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [_card, contents] = String.split(line, ": ")

    contents
    |> String.split(" | ")
    |> Enum.map(fn part ->
      part |> String.split() |> MapSet.new(&String.to_integer/1)
    end)
    |> then(fn [winning, scratch] -> MapSet.intersection(winning, scratch) |> MapSet.size() end)
  end

  @doc ~S"""
      iex> sample() |> part_1()
      13

      iex> input() |> part_1()
      23673
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.map(fn
      0 -> 0
      num -> 2 ** (num - 1)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      30

      iex> input() |> part_2()
      12263631
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&{1, &1})
    |> count_cards()
  end

  defp count_cards(queue, acc \\ 0)
  defp count_cards([], acc), do: acc

  defp count_cards([{count, score} | queue], acc) do
    queue
    |> Enum.split(score)
    |> then(fn {left, right} ->
      left
      |> Enum.map(fn {c, score} -> {c + count, score} end)
      |> Kernel.++(right)
    end)
    |> count_cards(acc + count)
  end
end
