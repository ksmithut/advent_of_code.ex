defmodule Y2023.D02 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/2
  https://adventofcode.com/2023/day/2/input
  """

  def input, do: Path.join(["input", "2023", "02.txt"]) |> File.read!()

  def sample do
    """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [game_prefix, sets_line] = String.split(line, ": ")
    id = game_prefix |> String.replace(~r/[^\d]+/, "") |> String.to_integer()

    sets =
      sets_line
      |> String.split("; ")
      |> Enum.map(fn set ->
        set
        |> String.split(", ")
        |> Map.new(fn color ->
          [amount, color] = String.split(color)
          {color, String.to_integer(amount)}
        end)
      end)

    {id, sets}
  end

  @doc ~S"""
      iex> sample() |> part_1()
      8

      iex> input() |> part_1()
      2169
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.filter(fn {_, sets} ->
      Enum.all?(sets, fn set ->
        red = Map.get(set, "red", 0)
        green = Map.get(set, "green", 0)
        blue = Map.get(set, "blue", 0)
        red <= 12 and green <= 13 and blue <= 14
      end)
    end)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      2286

      iex> input() |> part_2()
      60948
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Stream.map(&elem(&1, 1))
    |> Stream.map(fn sets ->
      ["red", "green", "blue"]
      |> Enum.map(fn color ->
        sets |> get_in([Access.all(), color]) |> Enum.filter(& &1) |> Enum.max(fn -> 0 end)
      end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end
end
