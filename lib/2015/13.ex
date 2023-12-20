defmodule Y2015.D13 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2015/day/13
  https://adventofcode.com/2015/day/13/input
  """

  def input, do: Path.join(["input", "2015", "13.txt"]) |> File.read!()

  def sample do
    """
    Alice would gain 54 happiness units by sitting next to Bob.
    Alice would lose 79 happiness units by sitting next to Carol.
    Alice would lose 2 happiness units by sitting next to David.
    Bob would gain 83 happiness units by sitting next to Alice.
    Bob would lose 7 happiness units by sitting next to Carol.
    Bob would lose 63 happiness units by sitting next to David.
    Carol would lose 62 happiness units by sitting next to Alice.
    Carol would gain 60 happiness units by sitting next to Bob.
    Carol would gain 55 happiness units by sitting next to David.
    David would gain 46 happiness units by sitting next to Alice.
    David would lose 7 happiness units by sitting next to Bob.
    David would gain 41 happiness units by sitting next to Carol.
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      330

      iex> input() |> part_1()
      618
  """
  def part_1(input) do
    input
    |> parse_input()
    |> find_max_happiness()
  end

  @line_regex ~r/^(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+).$/
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, map ->
      [_, name, sign, happiness, neighbor] = Regex.run(@line_regex, line)
      points = parse_happiness(sign, happiness)
      Map.update(map, name, %{neighbor => points}, &Map.put(&1, neighbor, points))
    end)
  end

  defp parse_happiness("gain", points), do: String.to_integer(points)
  defp parse_happiness("lose", points), do: -String.to_integer(points)

  defp find_max_happiness(people) do
    people
    |> Map.keys()
    |> Permutations.of()
    |> Enum.map(&Enum.chunk_every(&1, 2, 1, [hd(&1)]))
    |> Enum.map(fn combo ->
      combo
      |> Enum.map(fn [person, neighbor] ->
        get_in(people, [person, neighbor]) + get_in(people, [neighbor, person])
      end)
      |> Enum.sum()
    end)
    |> Enum.max()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      286

      iex> input() |> part_2()
      601
  """
  def part_2(input) do
    input
    |> parse_input()
    |> insert_self()
    |> find_max_happiness()
  end

  defp insert_self(people) do
    Enum.reduce(people, people, fn {person, _}, people ->
      people
      |> Map.update!(person, &Map.put(&1, :self, 0))
      |> Map.update(:self, %{person => 0}, &Map.put(&1, person, 0))
    end)
  end
end
