import AdventOfCode

solution 2022, 24 do
  @moduledoc """
  https://adventofcode.com/2022/day/24
  https://adventofcode.com/2022/day/24/input
  """

  def sample do
    """
    #.######
    #>>.<^<#
    #.<..<<#
    #>v.><>#
    #<^v^^>#
    ######.#
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      18

      iex> input() |> part_1()
      311
  """
  def part_1(input) do
    grid = parse_input(input)
    ranges = wind_ranges(grid)
    blizzards = get_blizzard_timeline(grid, ranges)
    {start, finish} = get_start_finish(grid)
    shortest_path({start, finish}, ranges, blizzards)
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, grid ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.into(grid, fn {v, x} -> {{x, y}, v} end)
    end)
  end

  defp ranges(grid) do
    keys = Map.keys(grid)
    {min_x, max_x} = keys |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = keys |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    {min_x..max_x, min_y..max_y}
  end

  defp get_start_finish(grid) do
    {min_x..max_x, min_y..max_y} = ranges(grid)
    {{min_x + 1, min_y}, {max_x - 1, max_y}}
  end

  defp wind_ranges(grid) do
    {min_x..max_x, min_y..max_y} = ranges(grid)
    {(min_x + 1)..(max_x - 1), (min_y + 1)..(max_y - 1)}
  end

  defp get_blizzard_timeline(map, ranges) do
    map
    |> Enum.filter(&(elem(&1, 1) in ["^", "v", "<", ">"]))
    |> Stream.iterate(&Enum.map(&1, fn {c, d} -> {next(c, d, ranges), d} end))
    |> Stream.map(&MapSet.new(&1, fn {c, _} -> c end))
    |> Stream.with_index()
    |> Enum.take(cycle_length(ranges))
    |> Map.new(fn {blizzard, minute} -> {minute, blizzard} end)
  end

  defp next({x, y}, "v", {_, min_y..max_y}) when (y + 1) in min_y..max_y, do: {x, y + 1}
  defp next({x, _y}, "v", {_, min_y.._}), do: {x, min_y}
  defp next({x, y}, "^", {_, min_y..max_y}) when (y - 1) in min_y..max_y, do: {x, y - 1}
  defp next({x, _y}, "^", {_, _..max_y}), do: {x, max_y}
  defp next({x, y}, ">", {min_x..max_x, _}) when (x + 1) in min_x..max_x, do: {x + 1, y}
  defp next({_x, y}, ">", {min_x.._, _}), do: {min_x, y}
  defp next({x, y}, "<", {min_x..max_x, _}) when (x - 1) in min_x..max_x, do: {x - 1, y}
  defp next({_x, y}, "<", {_..max_x, _}), do: {max_x, y}

  defp cycle_length({_..max_x, _..max_y}), do: lcd(max_x, max_y)
  defp lcd(a, b), do: div(a * b, Integer.gcd(a, b))

  defp shortest_path(minute \\ 1, {from, to}, ranges, blizzards) do
    shortest_path(%{from => true}, minute, {from, to}, ranges, blizzards)
  end

  defp shortest_path(queue, minute, {_, to}, _, _) when is_map_key(queue, to), do: minute

  defp shortest_path(queue, minute, {from, to}, ranges, blizzards) do
    minute_index = rem(minute + 1, map_size(blizzards))
    blizzard = blizzards[minute_index]

    queue
    |> Map.keys()
    |> Enum.flat_map(&possible_moves(&1, ranges, {from, to}))
    |> Enum.reject(&(&1 in blizzard))
    |> Map.new(&{&1, true})
    |> shortest_path(minute + 1, {from, to}, ranges, blizzards)
  end

  defp moves({x, y}), do: [{x, y}, {x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  defp possible_moves({x, y}, {x_range, y_range}, {from, to}) do
    {x, y}
    |> moves()
    |> Enum.filter(fn
      ^from -> true
      ^to -> true
      {x, y} -> x in x_range and y in y_range
    end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      54

      iex> input() |> part_2()
      869
  """
  def part_2(input) do
    grid = parse_input(input)
    ranges = wind_ranges(grid)
    blizzards = get_blizzard_timeline(grid, ranges)
    {start, finish} = get_start_finish(grid)

    shortest_path({start, finish}, ranges, blizzards)
    |> shortest_path({finish, start}, ranges, blizzards)
    |> shortest_path({start, finish}, ranges, blizzards)
  end
end
