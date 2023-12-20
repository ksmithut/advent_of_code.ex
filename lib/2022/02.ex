defmodule Y2022.D02 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/2
  https://adventofcode.com/2022/day/2/input
  """

  def input, do: Path.join(["input", "2022", "02.txt"]) |> File.read!()

  def sample do
    """
    A Y
    B X
    C Z
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      15

      iex> input() |> part_1()
      14827
  """
  def part_1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  # Rock vs
  defp score("A X"), do: 1 + 3
  defp score("A Y"), do: 2 + 6
  defp score("A Z"), do: 3 + 0
  # Paper vs
  defp score("B X"), do: 1 + 0
  defp score("B Y"), do: 2 + 3
  defp score("B Z"), do: 3 + 6
  # Scissors vs
  defp score("C X"), do: 1 + 6
  defp score("C Y"), do: 2 + 0
  defp score("C Z"), do: 3 + 3

  @doc ~S"""
      iex> sample() |> part_2()
      12

      iex> input() |> part_2()
      13889
  """
  def part_2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&score_2/1)
    |> Enum.sum()
  end

  # Rock vs
  defp score_2("A X"), do: 3 + 0
  defp score_2("A Y"), do: 1 + 3
  defp score_2("A Z"), do: 2 + 6
  # Paper vs
  defp score_2("B X"), do: 1 + 0
  defp score_2("B Y"), do: 2 + 3
  defp score_2("B Z"), do: 3 + 6
  # Scissors vs
  defp score_2("C X"), do: 2 + 0
  defp score_2("C Y"), do: 3 + 3
  defp score_2("C Z"), do: 1 + 6
end
