import AdventOfCode

solution 2020, 1 do
  @moduledoc """
  https://adventofcode.com/2020/day/1
  https://adventofcode.com/2020/day/1/input
  """

  def sample do
    """
    1721
    979
    366
    299
    675
    1456
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      514579

      iex> input() |> part_1()
      878724
  """
  def part_1(input) do
    input
    |> parse()
    |> find_value(2020, 2)
  end

  defp parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp find_value(nums, value, length, acc \\ [])

  defp find_value(nums, value, 1, acc) do
    Enum.find_value(nums, fn
      ^value -> [value | acc] |> Enum.product()
      _ -> false
    end)
  end

  defp find_value(nums, value, length, acc) do
    Enum.find_value(nums, &find_value(nums, value - &1, length - 1, [&1 | acc]))
  end

  @doc ~S"""
      iex> sample() |> part_2()
      241861950

      iex> input() |> part_2()
      201251610
  """
  def part_2(input) do
    input
    |> parse()
    |> find_value(2020, 3)
  end
end
