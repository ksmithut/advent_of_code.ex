import AdventOfCode

solution 2015, 10 do
  @moduledoc """
  https://adventofcode.com/2015/day/10
  https://adventofcode.com/2015/day/10/input
  """

  @doc ~S"""
      iex> "1" |> part_1(1)
      2

      iex> "11" |> part_1(1)
      2

      iex> "21" |> part_1(1)
      4

      iex> "1211" |> part_1(1)
      6

      iex> "111221" |> part_1(1)
      6

      iex> input() |> part_1()
      252594
  """
  def part_1(input, times \\ 40) do
    input
    |> String.trim()
    |> look_and_say(times)
    |> String.length()
  end

  defp look_and_say(str) do
    String.replace(str, ~r/(.)\1*/, fn match ->
      [String.length(match), String.first(match)] |> Enum.join()
    end)
  end

  defp look_and_say(str, times) when times <= 0, do: str
  defp look_and_say(str, times), do: str |> look_and_say() |> look_and_say(times - 1)

  @doc ~S"""
      iex> input() |> part_2()
      3579328
  """
  def part_2(input) do
    part_1(input, 50)
  end
end
