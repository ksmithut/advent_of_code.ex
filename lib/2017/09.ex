import AdventOfCode

solution 2017, 9 do
  @moduledoc """
  https://adventofcode.com/2017/day/9
  https://adventofcode.com/2017/day/9/input
  """

  @doc ~S"""
      iex> "{}" |> part_1()
      1

      iex> "{{{}}}" |> part_1()
      6

      iex> "{{},{}}" |> part_1()
      5

      iex> "{{{},{},{{}}}}" |> part_1()
      16

      iex> "{<a>,<a>,<a>,<a>}" |> part_1()
      1

      iex> "{{<ab>},{<ab>},{<ab>},{<ab>}}" |> part_1()
      9

      iex> "{{<!!>},{<!!>},{<!!>},{<!!>}}" |> part_1()
      9

      iex> "{{<a!>},{<a!>},{<a!>},{<ab>}}" |> part_1()
      3

      iex> input() |> part_1()
      8337
  """
  def part_1(input) do
    input
    |> String.replace(~r/!./, "")
    |> String.replace(~r/<[^>]*>/, "")
    |> score_groups()
  end

  defp score_groups(string, depth \\ 0, score \\ 0)
  defp score_groups("", _, total), do: total

  defp score_groups("{" <> rest, depth, total) do
    score_groups(rest, depth + 1, total + depth + 1)
  end

  defp score_groups("}" <> rest, depth, total) do
    score_groups(rest, depth - 1, total)
  end

  defp score_groups(<<_::8, rest::binary>>, depth, total) do
    score_groups(rest, depth, total)
  end

  @doc ~S"""
      iex> "<>" |> part_2()
      0

      iex> "<random characters>" |> part_2()
      17

      iex> "<<<<>" |> part_2()
      3

      iex> "<{!>}>" |> part_2()
      2

      iex> "<!!>" |> part_2()
      0

      iex> "<!!!>>" |> part_2()
      0

      iex> ~s(<{o"i!a,<{i<a>) |> part_2()
      10

      iex> input() |> part_2()
      4330
  """
  def part_2(input) do
    cleaned =
      input
      |> String.replace(~r/!./, "")
      |> String.replace(~r/<[^>]*>/, "<>")
      |> String.length()

    input
    |> String.replace(~r/!./, "")
    |> String.length()
    |> then(&(&1 - cleaned))
  end
end
