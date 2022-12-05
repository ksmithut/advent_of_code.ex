import AdventOfCode

solution 2015, 9 do
  @moduledoc """
  https://adventofcode.com/2015/day/9
  https://adventofcode.com/2015/day/9/input
  """

  def sample do
    """
    London to Dublin = 464
    London to Belfast = 518
    Dublin to Belfast = 141
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      605

      iex> input() |> part_1()
      251
  """
  def part_1(input) do
    input
    |> parse_input()
    |> all_distances()
    |> Enum.min()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, map ->
      [from, "to", to, "=", distance] = String.split(line)
      distance = String.to_integer(distance)

      map
      |> Map.update(from, %{to => distance}, &Map.put(&1, to, distance))
      |> Map.update(to, %{from => distance}, &Map.put(&1, from, distance))
    end)
  end

  defp all_distances(map) do
    map
    |> Map.keys()
    |> Permutations.of()
    |> Enum.map(fn permutation ->
      permutation
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&get_in(map, &1))
      |> Enum.sum()
    end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      982

      iex> input() |> part_2()
      898
  """
  def part_2(input) do
    input
    |> parse_input()
    |> all_distances()
    |> Enum.max()
  end
end
