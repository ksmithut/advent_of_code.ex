defmodule Y2023.D01 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/1
  https://adventofcode.com/2023/day/1/input
  """

  def input, do: Path.join(["input", "2023", "01.txt"]) |> File.read!()

  @doc ~S"""
      iex> "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet" |> part_1()
      142

      iex> input() |> part_1()
      56042
  """
  def part_1(input) do
    input
    |> String.split()
    |> Stream.map(&calibration_value/1)
    |> Enum.sum()
  end

  defp calibration_value(line) do
    line
    |> String.replace(~r/[^\d]/, "")
    |> String.to_integer()
    |> Integer.digits()
    |> then(&[List.first(&1), List.last(&1)])
    |> Integer.undigits()
  end

  @doc ~S"""
      iex> "two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen" |> part_2()
      281

      iex> input() |> part_2()
      55358
  """
  def part_2(input) do
    input
    |> String.split()
    |> Stream.map(&replace_words/1)
    |> Stream.map(&calibration_value/1)
    |> Enum.sum()
  end

  defp replace_words(line, acc \\ "")
  defp replace_words("", acc), do: acc
  defp replace_words("one" <> rest, acc), do: replace_words("e" <> rest, acc <> "1")
  defp replace_words("two" <> rest, acc), do: replace_words("o" <> rest, acc <> "2")
  defp replace_words("three" <> rest, acc), do: replace_words("e" <> rest, acc <> "3")
  defp replace_words("four" <> rest, acc), do: replace_words(rest, acc <> "4")
  defp replace_words("five" <> rest, acc), do: replace_words("e" <> rest, acc <> "5")
  defp replace_words("six" <> rest, acc), do: replace_words(rest, acc <> "6")
  defp replace_words("seven" <> rest, acc), do: replace_words("n" <> rest, acc <> "7")
  defp replace_words("eight" <> rest, acc), do: replace_words("t" <> rest, acc <> "8")
  defp replace_words("nine" <> rest, acc), do: replace_words("e" <> rest, acc <> "9")
  defp replace_words(<<c::size(8)>> <> rest, acc), do: replace_words(rest, acc <> <<c>>)

  # defp replace_words(line) do
  #   line
  #   |> String.replace("one", "o1e")
  #   |> String.replace("two", "t2o")
  #   |> String.replace("three", "th3ee")
  #   |> String.replace("four", "fo4r")
  #   |> String.replace("five", "fi5e")
  #   |> String.replace("six", "s6x")
  #   |> String.replace("seven", "se7en")
  #   |> String.replace("eight", "e8t")
  #   |> String.replace("nine", "n9e")
  # end
end
