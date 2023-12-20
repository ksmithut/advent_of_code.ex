defmodule Y2022.D06 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/6
  https://adventofcode.com/2022/day/6/input
  """

  def input, do: Path.join(["input", "2022", "06.txt"]) |> File.read!()

  @doc ~S"""
      iex> "bvwbjplbgvbhsrlpgdmjqwftvncz" |> part_1()
      5

      iex> "nppdvjthqldpwncqszvftbrmjlhg" |> part_1()
      6

      iex> "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" |> part_1()
      10

      iex> "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" |> part_1()
      11

      iex> input() |> part_1()
      1920
  """
  def part_1(input) do
    find_first_marker(input, 4)
  end

  defp find_first_marker(input, unique_length) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Stream.chunk_every(unique_length, 1)
    |> Stream.with_index(unique_length)
    |> Enum.find(fn {chunk, _} -> Enum.uniq(chunk) == chunk end)
    |> elem(1)
  end

  @doc ~S"""
      iex> "mjqjpqmgbljsphdztnvjfqwrcgsmlb" |> part_2()
      19

      iex> "bvwbjplbgvbhsrlpgdmjqwftvncz" |> part_2()
      23

      iex> "nppdvjthqldpwncqszvftbrmjlhg" |> part_2()
      23

      iex> "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" |> part_2()
      29

      iex> "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" |> part_2()
      26

      iex> input() |> part_2()
      2334
  """
  def part_2(input) do
    find_first_marker(input, 14)
  end
end
