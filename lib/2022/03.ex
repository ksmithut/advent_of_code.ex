import AdventOfCode

solution 2022, 3 do
  @moduledoc """
  https://adventofcode.com/2022/day/3
  https://adventofcode.com/2022/day/3/input
  """

  def sample do
    """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      157

      iex> input() |> part_1()
      8515
  """
  def part_1(input) do
    input
    |> String.split()
    |> Enum.map(fn line ->
      {left, right} = line |> String.graphemes() |> split_in_half()
      MapSet.intersection(MapSet.new(left), MapSet.new(right)) |> get_priority()
    end)
    |> Enum.sum()
  end

  defp split_in_half(list), do: Enum.split(list, div(length(list), 2))

  defp get_priority(mapset) do
    mapset
    |> MapSet.to_list()
    |> List.first()
    |> String.to_charlist()
    |> List.first()
    |> priority()
  end

  defp priority(c) when c in ?A..?Z, do: c - ?A + 27
  defp priority(c) when c in ?a..?z, do: c - ?a + 1

  @doc ~S"""
      iex> sample() |> part_2()
      70

      iex> input() |> part_2()
      2434
  """

  def part_2(input) do
    input
    |> String.split()
    |> Enum.chunk_every(3)
    |> Enum.map(fn [one, two, three] ->
      [one, two, three] = Enum.map([one, two, three], &MapSet.new(String.graphemes(&1)))

      one
      |> MapSet.intersection(two)
      |> MapSet.intersection(three)
      |> get_priority()
    end)
    |> Enum.sum()
  end
end
