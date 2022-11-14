import AdventOfCode

solution 2021, 1 do
  @moduledoc """
  https://adventofcode.com/2021/day/1
  https://adventofcode.com/2021/day/1/input
  """

  def sample do
    """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      7

      iex> input() |> part_1()
      1665
  """
  def part_1(input) do
    input
    |> parse()
    |> count_increases()
  end

  defp parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp count_increases(nums) do
    nums
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      5

      iex> input() |> part_2()
      1702
  """
  def part_2(input) do
    input
    |> parse()
    |> rolling_sums(3)
    |> count_increases()
  end

  defp rolling_sums(nums, window) do
    nums
    |> Enum.chunk_every(window, 1, :discard)
    |> Enum.map(&Enum.sum/1)
  end
end
