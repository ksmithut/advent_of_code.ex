defmodule Y2015.D04 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/4
  https://adventofcode.com/2015/day/4/input
  """

  def input, do: Path.join(["input", "2015", "04.txt"]) |> File.read!()

  @doc ~S"""
      iex> "abcdef" |> part_1()
      609043

      iex> "pqrstuv" |> part_1()
      1048970

      iex> input() |> part_1()
      282749
  """
  def part_1(input, starts_with \\ "00000") do
    input
    |> hash_stream()
    |> Enum.find(fn {_num, hash} -> String.starts_with?(hash, starts_with) end)
    |> elem(0)
  end

  defp hash(secret, number),
    do: {number, :crypto.hash(:md5, secret <> Integer.to_string(number)) |> Base.encode16()}

  defp hash_stream(secret) do
    secret = String.trim(secret)

    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(&hash(secret, &1))
  end

  @doc ~S"""
      iex> input() |> part_2()
      9962624
  """
  def part_2(input) do
    part_1(input, "000000")
  end
end
