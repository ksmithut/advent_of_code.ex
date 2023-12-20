defmodule Y2015.D08 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/8
  https://adventofcode.com/2015/day/8/input
  """

  def input, do: Path.join(["input", "2015", "08.txt"]) |> File.read!()

  @doc ~S"""
      iex> "\"\"" |> part_1()
      2

      iex> "\"abc\"" |> part_1()
      2

      iex> "\"aaa\\\"aaa\"" |> part_1()
      3

      iex> "\"\\x27\"" |> part_1()
      5

      iex> input() |> part_1()
      1371
  """
  def part_1(input) do
    input
    |> String.split()
    |> Enum.map(fn encoded ->
      String.length(encoded) - String.length(decode(encoded))
    end)
    |> Enum.sum()
  end

  defp decode(str) do
    str
    |> String.replace(~r/^"(.*)"$/, "\\1")
    |> String.replace(~r/\\x([0-9a-f]{2})/, fn match ->
      match
      |> String.replace(~r/^\\x/, "")
      |> String.to_integer(16)
      |> then(&to_string([&1]))
    end)
    |> String.replace(~r/\\(.)/, "\\1")
  end

  @doc ~S"""
      iex> "\"\"" |> part_2()
      4

      iex> "\"abc\"" |> part_2()
      4

      iex> "\"aaa\\\"aaa\"" |> part_2()
      6

      iex> "\"\\x27\"" |> part_2()
      5

      iex> input() |> part_2()
      2117
  """
  def part_2(input) do
    input
    |> String.split()
    |> Enum.map(fn encoded ->
      String.length(encode(encoded)) - String.length(encoded)
    end)
    |> Enum.sum()
  end

  defp encode(str) do
    str
    |> String.replace(~r/(\\|")/, "\\\\1")
    |> then(&"\"#{&1}\"")
  end
end
