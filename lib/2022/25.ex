import AdventOfCode

solution 2022, 25 do
  @moduledoc """
  https://adventofcode.com/2022/day/25
  https://adventofcode.com/2022/day/25/input
  """

  def sample do
    """
    1=-0-2
    12111
    2=0=
    21
    2=01
    111
    20012
    112
    1=-1=
    1-12
    12
    1=
    122
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      "2=-1=0"

      # iex> input() |> part_1()
      # input()
  """
  def part_1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&decode_snafu/1)
    |> Enum.sum()
    |> encode_snafu()
  end

  defp decode_snafu("2"), do: 2
  defp decode_snafu("1"), do: 1
  defp decode_snafu("0"), do: 0
  defp decode_snafu("-"), do: -1
  defp decode_snafu("="), do: -2

  defp decode_snafu(value) do
    value
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {char, index}, total -> total + decode_snafu(char) * 5 ** index end)
  end

  defp encode_snafu(value, digits \\ [])

  defp encode_snafu(0, digits), do: digits |> Enum.join()

  defp encode_snafu(value, digits) do
    char =
      case rem(value + 2, 5) do
        4 -> "2"
        3 -> "1"
        2 -> "0"
        1 -> "-"
        0 -> "="
      end

    (value + 2) |> div(5) |> encode_snafu([char | digits])
  end

  @doc ~S"""
      iex> "" |> part_2()
      ""

      iex> input() |> part_2()
      input()
  """
  def part_2(input) do
    input
  end
end
