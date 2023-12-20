defmodule Y2023.D03 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/3
  https://adventofcode.com/2023/day/3/input
  """

  def input, do: Path.join(["input", "2023", "03.txt"]) |> File.read!()

  def sample do
    """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Stream.map(&parse_char/1)
      |> Stream.with_index()
      |> Stream.chunk_by(fn
        {val, _} when is_integer(val) -> true
        {_, index} -> index
      end)
      |> Stream.flat_map(&parse_chunk(&1, y))
    end)
    |> Map.new()
  end

  defp parse_chunk([{nil, _x}], _y), do: []
  defp parse_chunk([{val, x}], y) when is_binary(val), do: [{{x, y}, val}]

  defp parse_chunk(chunk, y) do
    number = chunk |> Enum.map(&elem(&1, 0)) |> Integer.undigits()
    pos = chunk |> Enum.map(&{elem(&1, 1), y})
    [{pos, number}]
  end

  defp parse_char("."), do: nil

  defp parse_char(char) do
    case Integer.parse(char) do
      :error -> char
      {number, _} -> number
    end
  end

  @doc ~S"""
      iex> sample() |> part_1()
      4361

      iex> input() |> part_1()
      556057
  """
  def part_1(input) do
    grid = parse_input(input)

    grid
    |> Stream.filter(&is_integer(elem(&1, 1)))
    |> Stream.filter(fn {positions, _} ->
      positions
      |> Stream.flat_map(&neighbors/1)
      |> Enum.any?(&grid[&1])
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp neighbors({x, y}),
    do: [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]

  @doc ~S"""
      iex> sample() |> part_2()
      467835

      iex> input() |> part_2()
      82824352
  """
  def part_2(input) do
    grid = parse_input(input)

    {ref_map, ref_grid} =
      grid
      |> Stream.filter(&is_integer(elem(&1, 1)))
      |> Enum.reduce({%{}, %{}}, fn {pos, value}, {map, grid} ->
        ref = make_ref()
        {Map.put(map, ref, value), Enum.into(pos, grid, &{&1, ref})}
      end)

    grid
    |> Stream.filter(&match?({_, "*"}, &1))
    |> Stream.map(fn {pos, _} ->
      pos
      |> neighbors()
      |> Enum.map(&ref_grid[&1])
      |> Enum.filter(& &1)
      |> MapSet.new()
      |> Enum.to_list()
      |> case do
        [ref1, ref2] -> ref_map[ref1] * ref_map[ref2]
        _ -> 0
      end
    end)
    |> Enum.sum()
  end
end
