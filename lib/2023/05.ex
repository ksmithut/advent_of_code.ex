defmodule Y2023.D05 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/5
  https://adventofcode.com/2023/day/5/input
  """

  def input, do: Path.join(["input", "2023", "05.txt"]) |> File.read!()

  def sample do
    """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n", trim: true)
    |> Stream.map(&parse_section/1)
    |> Map.new()
  end

  defp parse_section("seeds: " <> seeds) do
    {:source, {"seed", seeds |> String.split() |> Enum.map(&String.to_integer/1)}}
  end

  @heading_regex ~r/(?<from>\w+)-to-(?<to>\w+) map:/
  defp parse_section(section) do
    [heading | mappings] = String.split(section, "\n", trim: true)
    %{"from" => from, "to" => to} = Regex.named_captures(@heading_regex, heading)
    mappings = mappings |> Enum.map(&parse_mapping/1) |> Enum.sort_by(fn {a.._, _} -> a end)
    {from, {to, mappings}}
  end

  def parse_mapping(mapping) do
    [destination, source, length] = mapping |> String.split() |> Enum.map(&String.to_integer/1)
    {source..(source + length - 1), destination..(destination + length - 1)}
  end

  @doc ~S"""
      iex> sample() |> part_1()
      35

      iex> input() |> part_1()
      388071289
  """
  def part_1(input) do
    input
    |> parse_input()
    |> map_seed_locations()
    |> Enum.min()
  end

  defp map_seed_locations(map) do
    map_seed_locations(map.source, map)
  end

  defp map_seed_locations({target, items}, map) when is_map_key(map, target) do
    {new_target, ranges} = map[target]

    items
    |> Enum.map(fn item ->
      Enum.find_value(ranges, item, fn {a1.._ = a, b1.._} ->
        if item in a, do: b1 + (item - a1)
      end)
    end)
    |> then(&{new_target, &1})
    |> map_seed_locations(map)
  end

  defp map_seed_locations({_, items}, _), do: items

  @doc ~S"""
      iex> sample() |> part_2()
      46

      iex> input() |> part_2()
      84206669
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Map.update!(:source, fn {target, seeds} ->
      seeds
      |> Stream.chunk_every(2)
      |> Enum.map(fn [a, b] -> a..(a + b - 1) end)
      |> then(&{target, &1})
    end)
    |> map_seed_range_locations()
    |> hd()
    |> then(& &1.first)
  end

  defp map_seed_range_locations(map) do
    map_seed_range_locations(map.source, map)
  end

  defp map_seed_range_locations({target, items}, map) when is_map_key(map, target) do
    {new_target, ranges} = map[target]

    apply_ranges(items, ranges)
    |> then(&{new_target, &1})
    |> map_seed_range_locations(map)
  end

  defp map_seed_range_locations({_, items}, _), do: items

  defp apply_ranges(items, ranges) do
    apply_ranges(items |> Enum.sort_by(& &1.first), ranges, [])
  end

  defp apply_ranges([], _, acc), do: Enum.sort_by(acc, & &1.first)
  defp apply_ranges([item | rest], [], acc), do: apply_ranges(rest, [], [item | acc])

  defp apply_ranges([item | rest_items], [{src, dest} | rest_ranges] = ranges, acc) do
    map_range = fn a..b -> (dest.first + (a - src.first))..(dest.first + (b - src.first)) end
    {a, b, c} = split(item, src)
    acc = if a, do: [a | acc], else: acc
    acc = if b, do: [map_range.(b) | acc], else: acc
    items = if c, do: [c | rest_items], else: rest_items
    ranges = if c, do: rest_ranges, else: ranges
    apply_ranges(items, ranges, acc)
  end

  defp split(a1..a2, b1.._) when a2 < b1, do: {a1..a2, nil, nil}
  defp split(a1..a2, b1..b2) when a1 >= b1 and a2 <= b2, do: {nil, a1..a2, nil}
  defp split(a1..a2, _..b2) when a1 > b2, do: {nil, nil, a1..a2}

  defp split(a1..a2, b1..b2) when a1 < b1 and a2 >= b1 and a2 <= b2,
    do: {a1..(b1 - 1), b1..a2, nil}

  defp split(a1..a2, b1..b2) when a1 >= b1 and a1 <= b2 and a2 > b2,
    do: {nil, a1..b2, (b2 + 1)..a2}

  defp split(a1..a2, b1..b2) when a1 < b1 and a2 > b2, do: {a1..(b1 - 1), b1..b2, (b2 + 1)..a2}
end
