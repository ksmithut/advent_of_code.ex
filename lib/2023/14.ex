defmodule Y2023.D14 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/14
  https://adventofcode.com/2023/day/14/input
  """

  def input, do: Path.join(["input", "2023", "14.txt"]) |> File.read!()

  def sample do
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Enum.reduce({%{}, {0, 0}}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.reduce(acc, fn
        {".", x}, {grid, {mx, my}} -> {grid, {max(x, mx), max(y, my)}}
        {char, x}, {grid, {mx, my}} -> {Map.put(grid, {x, y}, char), {max(x, mx), max(y, my)}}
      end)
    end)
    |> then(fn {grid, {x, y}} ->
      {grid, {0..x, 0..y}}
    end)
  end

  @doc ~S"""
      iex> sample() |> part_1()
      136

      iex> input() |> part_1()
      111979
  """
  def part_1(input) do
    {grid, ranges} = parse_input(input)
    {_, _..max_y} = ranges

    grid
    |> tilt(ranges, :north)
    |> load(max_y)
  end

  defp tilt(grid, ranges, dir) do
    grid
    |> get_rounds()
    |> sort_coords(dir)
    |> Enum.reduce(grid, fn rock, grid ->
      roll(rock, grid, ranges, dir)
    end)
  end

  def get_rounds(grid) do
    grid
    |> Stream.filter(&match?({_, "O"}, &1))
    |> Stream.map(&elem(&1, 0))
  end

  defp sort_coords(coords, :north), do: Enum.sort_by(coords, &elem(&1, 1), :asc)
  defp sort_coords(coords, :south), do: Enum.sort_by(coords, &elem(&1, 1), :desc)
  defp sort_coords(coords, :east), do: Enum.sort_by(coords, &elem(&1, 0), :desc)
  defp sort_coords(coords, :west), do: Enum.sort_by(coords, &elem(&1, 0), :asc)

  def roll({x, y}, grid, {_, min_y.._}, :north) do
    grid = Map.delete(grid, {x, y})
    y = Enum.find(y..min_y, min_y - 1, &is_map_key(grid, {x, &1})) + 1
    Map.put(grid, {x, y}, "O")
  end

  def roll({x, y}, grid, {_, _..max_y}, :south) do
    grid = Map.delete(grid, {x, y})
    y = Enum.find(y..max_y, max_y + 1, &is_map_key(grid, {x, &1})) - 1
    Map.put(grid, {x, y}, "O")
  end

  def roll({x, y}, grid, {_..max_x, _}, :east) do
    grid = Map.delete(grid, {x, y})
    x = Enum.find(x..max_x, max_x + 1, &is_map_key(grid, {&1, y})) - 1
    Map.put(grid, {x, y}, "O")
  end

  def roll({x, y}, grid, {min_x.._, _}, :west) do
    grid = Map.delete(grid, {x, y})
    x = Enum.find(x..min_x, min_x - 1, &is_map_key(grid, {&1, y})) + 1
    Map.put(grid, {x, y}, "O")
  end

  defp load(grid, max_y) do
    grid
    |> get_rounds()
    |> Stream.map(&(max_y + 1 - elem(&1, 1)))
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      64

      iex> input() |> part_2()
      102055
  """
  def part_2(input) do
    {grid, ranges} = parse_input(input)
    {_, _..max_y} = ranges

    {map, end_index, start_index} =
      Stream.iterate(grid, fn grid ->
        grid
        |> tilt(ranges, :north)
        |> tilt(ranges, :west)
        |> tilt(ranges, :south)
        |> tilt(ranges, :east)
      end)
      |> Stream.with_index(0)
      |> Enum.reduce_while(%{}, fn
        {grid, index}, mem when is_map_key(mem, grid) ->
          {:halt, {invert(mem), index, mem[grid]}}

        {grid, index}, mem ->
          {:cont, Map.put(mem, grid, index)}
      end)

    rem = rem(1_000_000_000 - start_index, end_index - start_index) + start_index
    load(map[rem], max_y)
  end

  defp invert(map), do: Map.new(map, fn {k, v} -> {v, k} end)
end
