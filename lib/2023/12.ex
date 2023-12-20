defmodule Y2023.D12 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/12
  https://adventofcode.com/2023/day/12/input
  """

  def input, do: Path.join(["input", "2023", "12.txt"]) |> File.read!()

  def sample do
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
  end

  defp parse_line(line) do
    [conditions, sizes] = String.split(line)
    sizes = sizes |> String.split(",") |> Enum.map(&String.to_integer/1)
    {conditions, sizes}
  end

  @doc ~S"""
      iex> sample() |> part_1()
      21

      iex> input() |> part_1()
      6488
  """
  def part_1(input) do
    mem_count_ways = Memoize.create(&count_ways/2)

    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&mem_count_ways.(&1))
    |> Enum.sum()
  end

  defp count_ways({"", []}, _call), do: 1
  defp count_ways({"", _runs}, _call), do: 0
  defp count_ways({line, []}, _call), do: if(String.contains?(line, "#"), do: 0, else: 1)

  defp count_ways({<<c::binary-size(1)>> <> tail = line, [run | rest] = runs}, call) do
    cond do
      String.length(line) < Enum.sum(runs) + length(runs) - 1 -> 0
      c == "." -> call.({tail, runs})
      c == "#" and String.slice(line, 0, run) |> String.contains?(".") -> 0
      c == "#" and String.at(line, run) == "#" -> 0
      c == "#" -> call.({String.slice(line, run + 1, String.length(line)), rest})
      true -> call.({"#" <> tail, runs}) + call.({"." <> tail, runs})
    end
  end

  @doc ~S"""
      iex> sample() |> part_2()
      525152

      iex> input() |> part_2()
      815364548481
  """
  def part_2(input) do
    mem_count_ways = Memoize.create(&count_ways/2)

    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      [conditions, sizes] = line |> String.split() |> Enum.map(&replicate(&1, 5))
      [Enum.join(conditions, "?"), Enum.join(sizes, ",")] |> Enum.join(" ")
    end)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&mem_count_ways.(&1))
    |> Enum.sum()
  end

  defp replicate(x, n), do: for(_ <- 1..n, do: x)
end
