defmodule Y2023.D08 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/8
  https://adventofcode.com/2023/day/8/input
  """

  def input, do: Path.join(["input", "2023", "08.txt"]) |> File.read!()

  def sample do
    """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
  end

  def sample_2 do
    """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
  end

  def sample_3 do
    """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
  end

  @line_regex ~r/^(?<source>\w+) = \((?<left>\w+), (?<right>\w+)\)$/

  defp parse_input(input) do
    [directions, map] = input |> String.trim() |> String.split("\n\n", trim: true)
    directions = directions |> String.graphemes() |> Stream.cycle() |> Stream.with_index()
    map = map |> String.split("\n") |> Map.new(&parse_line/1)
    {directions, map}
  end

  @line_regex ~r/^(?<source>\w+) = \((?<left>\w+), (?<right>\w+)\)$/
  defp parse_line(line) do
    captures = Regex.named_captures(@line_regex, line)
    {captures["source"], {captures["left"], captures["right"]}}
  end

  @doc ~S"""
      iex> sample() |> part_1()
      2

      iex> sample_2() |> part_1()
      6

      iex> input() |> part_1()
      21409
  """
  def part_1(input) do
    input
    |> parse_input()
    |> steps("AAA", &(&1 === "ZZZ"))
  end

  defp move_node(node, "L", map), do: elem(map[node], 0)
  defp move_node(node, "R", map), do: elem(map[node], 1)

  defp steps({directions, map}, start, stop?) do
    Enum.reduce_while(directions, start, fn {dir, index}, node ->
      if stop?.(node), do: {:halt, index}, else: {:cont, move_node(node, dir, map)}
    end)
  end

  @doc ~S"""
      iex> sample_3() |> part_2()
      6

      iex> input() |> part_2()
      21165830176709
  """
  def part_2(input) do
    {directions, map} = parse_input(input)

    map
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn node ->
      steps({directions, map}, node, &String.ends_with?(&1, "Z"))
    end)
    |> Math.least_common_multiple()
  end
end
