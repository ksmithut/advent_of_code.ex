defmodule Y2023.D11 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/11
  https://adventofcode.com/2023/day/11/input
  """

  def input, do: Path.join(["input", "2023", "11.txt"]) |> File.read!()

  def sample do
    """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Stream.with_index()
      |> Stream.filter(&match?({"#", _}, &1))
      |> Stream.map(&elem(&1, 1))
      |> Stream.map(&{&1, y})
    end)
    |> Enum.to_list()
  end

  @doc ~S"""
      iex> sample() |> part_1()
      374

      iex> input() |> part_1()
      10231178
  """
  def part_1(input, empty_modifier \\ 1) do
    galaxies = parse_input(input)
    empty_x = get_gaps_by(galaxies, &get_x/1)
    empty_y = get_gaps_by(galaxies, &get_y/1)

    galaxies
    |> pairs()
    |> Stream.map(fn {a, b} ->
      x = get_distance(get_x(a), get_x(b), empty_x, empty_modifier)
      y = get_distance(get_y(a), get_y(b), empty_y, empty_modifier)
      x + y
    end)
    |> Enum.sum()
  end

  defp get_x({x, _}), do: x
  defp get_y({_, y}), do: y

  defp pairs(list, acc \\ [])
  defp pairs([], acc), do: acc
  defp pairs([_], acc), do: acc
  defp pairs([a | rest], acc), do: pairs(rest, rest |> Enum.map(&{a, &1}) |> Enum.concat(acc))

  defp get_distance(a, b, empty_values, empty_modifier) do
    empty = Enum.count(a..b, &MapSet.member?(empty_values, &1))
    abs(a - b) + empty * empty_modifier
  end

  defp get_gaps_by(list, func) do
    values = Stream.map(list, func)
    set = MapSet.new(values)
    {min, max} = Enum.min_max(values)
    for value <- min..max, not MapSet.member?(set, value), into: MapSet.new(), do: value
  end

  @doc ~S"""
      iex> sample() |> part_2()
      82000210

      iex> input() |> part_2()
      622120986954
  """
  def part_2(input) do
    part_1(input, 999_999)
  end
end
