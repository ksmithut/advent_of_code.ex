defmodule Y2023.D09 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/9
  https://adventofcode.com/2023/day/9/input
  """

  def input, do: Path.join(["input", "2023", "09.txt"]) |> File.read!()

  def sample do
    """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&(&1 |> String.split() |> Enum.map(fn num -> String.to_integer(num) end)))
  end

  @doc ~S"""
      iex> sample() |> part_1()
      114

      iex> input() |> part_1()
      1708206096
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.map(&build_diff_stack/1)
    |> Stream.map(fn stack -> stack |> Enum.map(&Enum.reverse/1) end)
    |> Stream.map(&inc_diff_stack/1)
    |> Stream.map(&(&1 |> List.last() |> hd()))
    |> Enum.sum()
  end

  defp inc_diff_stack(stack, op \\ &Kernel.+/2) do
    stack
    |> Enum.reduce({0, []}, fn [head | _] = line, {inc, stack} ->
      inc = op.(head, inc)
      {inc, [[inc | line] | stack]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp build_diff_stack(list) do
    list
    |> Stream.iterate(&build_diff_sequence/1)
    |> Enum.reduce_while([], fn list, acc ->
      if Enum.all?(list, &(&1 == 0)), do: {:halt, [list | acc]}, else: {:cont, [list | acc]}
    end)
  end

  defp build_diff_sequence(list) do
    list
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.map(fn [a, b] -> b - a end)
    |> Enum.to_list()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      2

      iex> input() |> part_2()
      1050
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Stream.map(&build_diff_stack/1)
    |> Stream.map(&inc_diff_stack(&1, fn a, b -> a - b end))
    |> Stream.map(&(&1 |> List.last() |> hd()))
    |> Enum.sum()
  end
end
