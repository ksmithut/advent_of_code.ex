defmodule Y2015.D06 do
  @behaviour AdventOfCode

  import String, only: [to_integer: 1]

  @moduledoc """
  https://adventofcode.com/2015/day/6
  https://adventofcode.com/2015/day/6/input
  """

  def input, do: Path.join(["input", "2015", "06.txt"]) |> File.read!()

  @doc ~S"""
      iex> "turn on 0,0 through 999,999" |> part_1()
      1_000_000

      iex> "toggle 0,0 through 999,0" |> part_1()
      1_000

      iex> "turn on 0,0 through 999,999\nturn off 499,499 through 500,500" |> part_1()
      999_996

      iex> input() |> part_1()
      543903
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn
      {:on, x1, y1, x2, y2} -> {&on/1, x1, y1, x2, y2}
      {:off, x1, y1, x2, y2} -> {&off/1, x1, y1, x2, y2}
      {:toggle, x1, y1, x2, y2} -> {&toggle/1, x1, y1, x2, y2}
    end)
    |> Enum.reduce(%{}, &run_command/2)
    |> Enum.count(fn {_, val} -> val == 1 end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @line_regex ~r/^(?<command>turn on|toggle|turn off) (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)$/
  defp parse_line(line) do
    @line_regex
    |> Regex.run(line)
    |> parse_command()
    |> parse_integers()
  end

  defp parse_command([_, "turn on", x1, y1, x2, y2]), do: {:on, x1, y1, x2, y2}
  defp parse_command([_, "turn off", x1, y1, x2, y2]), do: {:off, x1, y1, x2, y2}
  defp parse_command([_, "toggle", x1, y1, x2, y2]), do: {:toggle, x1, y1, x2, y2}

  defp parse_integers({command, x1, y1, x2, y2}) do
    {command, to_integer(x1), to_integer(y1), to_integer(x2), to_integer(y2)}
  end

  defp on(_), do: 1
  defp off(_), do: 0
  defp toggle(0), do: 1
  defp toggle(1), do: 0

  defp run_command({command, x1, y1, x2, y2}, map) do
    for x <- x1..x2, y <- y1..y2, reduce: map do
      map -> Map.put(map, {x, y}, command.(Map.get(map, {x, y}, 0)))
    end
  end

  @doc ~S"""
      iex> "turn on 0,0 through 0,0" |> part_2()
      1

      iex> "toggle 0,0 through 999,999" |> part_2()
      2000000

      iex> input() |> part_2()
      14687245
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn
      {:on, x1, y1, x2, y2} -> {&nordic_on/1, x1, y1, x2, y2}
      {:off, x1, y1, x2, y2} -> {&nordic_off/1, x1, y1, x2, y2}
      {:toggle, x1, y1, x2, y2} -> {&nordic_toggle/1, x1, y1, x2, y2}
    end)
    |> Enum.reduce(%{}, &run_command/2)
    |> Map.values()
    |> Enum.sum()
  end

  defp nordic_on(val), do: val + 1
  defp nordic_off(val), do: max(0, val - 1)
  defp nordic_toggle(val), do: val + 2
end
