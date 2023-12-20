defmodule Y2023.D10 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/10
  https://adventofcode.com/2023/day/10/input
  """

  def input, do: Path.join(["input", "2023", "10.txt"]) |> File.read!()

  def sample do
    """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """
  end

  def sample_2 do
    """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """
  end

  def sample_3 do
    """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
  end

  def sample_4 do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end

  def sample_5 do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
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
      |> Stream.map(fn {char, x} -> {char, {x, y}} end)
      |> Stream.map(fn
        {"S", pos} -> {:start, pos}
        {"|", pos} -> {pos, [up(pos), down(pos)]}
        {"-", pos} -> {pos, [left(pos), right(pos)]}
        {"L", pos} -> {pos, [up(pos), right(pos)]}
        {"J", pos} -> {pos, [up(pos), left(pos)]}
        {"7", pos} -> {pos, [left(pos), down(pos)]}
        {"F", pos} -> {pos, [right(pos), down(pos)]}
        {".", pos} -> {pos, []}
      end)
    end)
    |> Map.new()
    |> then(fn grid ->
      connected = grid.start |> neighbors() |> Enum.filter(&(grid[&1] && grid.start in grid[&1]))
      Map.put(grid, grid.start, connected)
    end)
  end

  defp up({x, y}), do: {x, y - 1}
  defp down({x, y}), do: {x, y + 1}
  defp left({x, y}), do: {x - 1, y}
  defp right({x, y}), do: {x + 1, y}

  defp neighbors(pos), do: [up(pos), down(pos), left(pos), right(pos)]

  @doc ~S"""
      iex> sample() |> part_1()
      4

      iex> sample_2() |> part_1()
      8

      iex> input() |> part_1()
      6823
  """
  def part_1(input) do
    input
    |> parse_input()
    |> then(fn grid ->
      connected = grid.start |> neighbors() |> Enum.filter(&(grid[&1] && grid.start in grid[&1]))
      Map.put(grid, grid.start, connected)
    end)
    |> find_loop()
    |> length()
    |> div(2)
  end

  defp find_loop(grid) do
    find_loop(hd(grid[grid.start]), grid.start, grid.start, grid)
  end

  defp find_loop(curr, prev, target, grid, acc \\ [])
  defp find_loop(target, _, target, _, acc), do: [target | acc]

  defp find_loop(curr, prev, target, grid, acc) do
    grid[curr] |> Enum.find(&(&1 != prev)) |> find_loop(curr, target, grid, [curr | acc])
  end

  @doc ~S"""
      iex> sample_3() |> part_2()
      4

      iex> sample_4() |> part_2()
      8

      iex> sample_5() |> part_2()
      10

      iex> input() |> part_2()
      415
  """
  def part_2(input) do
    input
    |> inflate_input()
    |> parse_input()
    |> then(fn grid ->
      [&up/1, &down/1, &left/1, &right/1]
      |> Stream.map(&{&1.(grid.start), &1.(&1.(grid.start))})
      |> Stream.filter(fn {_, next} -> grid[next] && grid[next] != [] end)
      |> Enum.reduce(grid, fn {pos, next}, grid ->
        grid
        |> Map.put(pos, [next, grid.start])
        |> Map.update(grid.start, [pos], &[pos | &1])
      end)
    end)
    |> fill()
    |> Enum.filter(fn {x, y} -> rem(x, 3) == 1 and rem(y, 3) == 1 end)
    |> length()
  end

  defp fill(grid) do
    boundary = grid |> find_loop() |> Map.new(&{&1, []})

    [up(left(grid.start)), up(right(grid.start)), down(left(grid.start)), down(right(grid.start))]
    |> Enum.find_value(&fill([&1], grid, boundary, %{}))
  end

  defp fill([], _grid, _boundary, visited), do: visited |> Map.keys()

  defp fill([pos | queue], grid, boundary, visited)
       when is_map_key(visited, pos) or is_map_key(boundary, pos),
       do: fill(queue, grid, boundary, visited)

  defp fill([pos | _queue], grid, _boundary, _visited) when not is_map_key(grid, pos), do: nil

  defp fill([pos | queue], grid, boundary, visited) do
    pos
    |> neighbors()
    |> Enum.concat(queue)
    |> fill(grid, boundary, Map.put(visited, pos, []))
  end

  defp inflate_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.flat_map(fn line ->
      line
      |> String.graphemes()
      |> Stream.map(fn
        "|" -> [".|.", ".|.", ".|."]
        "-" -> ["...", "---", "..."]
        "L" -> [".|.", ".L-", "..."]
        "J" -> [".|.", "-J.", "..."]
        "7" -> ["...", "-7.", ".|."]
        "F" -> ["...", ".F-", ".|."]
        "." -> ["...", "...", "..."]
        "S" -> ["...", ".S.", "..."]
      end)
      |> Stream.zip()
      |> Stream.map(&Tuple.to_list/1)
      |> Stream.map(&Enum.join/1)
    end)
    |> Enum.join("\n")
  end
end
