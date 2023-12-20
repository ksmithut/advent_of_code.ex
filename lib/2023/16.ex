defmodule Y2023.D16 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/16
  https://adventofcode.com/2023/day/16/input
  """

  def input, do: Path.join(["input", "2023", "16.txt"]) |> File.read!()

  def sample do
    """
    .|...\\....
    |.-.\\.....
    .....|-...
    ........|.
    ..........
    .........\\
    ..../.\\\\..
    .-.-/..|..
    .|....-|.\\
    ..//.|....
    """
  end

  defp parse_input(input) do
    input
    |> String.split()
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Stream.with_index()
      |> Stream.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  @doc ~S"""
      iex> sample() |> part_1()
      46

      iex> input() |> part_1()
      7951
  """
  def part_1(input) do
    input
    |> parse_input()
    |> run_beams([{{0, 0}, :r}])
  end

  defp move({x, y}, :r), do: {{x + 1, y}, :r}
  defp move({x, y}, :l), do: {{x - 1, y}, :l}
  defp move({x, y}, :u), do: {{x, y - 1}, :u}
  defp move({x, y}, :d), do: {{x, y + 1}, :d}

  defp next_beams(".", {pos, dir}, beams), do: [move(pos, dir) | beams]
  defp next_beams("/", {pos, :u}, beams), do: [move(pos, :r) | beams]
  defp next_beams("/", {pos, :r}, beams), do: [move(pos, :u) | beams]
  defp next_beams("/", {pos, :d}, beams), do: [move(pos, :l) | beams]
  defp next_beams("/", {pos, :l}, beams), do: [move(pos, :d) | beams]
  defp next_beams("\\", {pos, :u}, beams), do: [move(pos, :l) | beams]
  defp next_beams("\\", {pos, :r}, beams), do: [move(pos, :d) | beams]
  defp next_beams("\\", {pos, :d}, beams), do: [move(pos, :r) | beams]
  defp next_beams("\\", {pos, :l}, beams), do: [move(pos, :u) | beams]
  defp next_beams("-", {pos, :r}, beams), do: [move(pos, :r) | beams]
  defp next_beams("-", {pos, :l}, beams), do: [move(pos, :l) | beams]
  defp next_beams("-", {pos, :u}, beams), do: [move(pos, :l), move(pos, :r) | beams]
  defp next_beams("-", {pos, :d}, beams), do: [move(pos, :l), move(pos, :r) | beams]
  defp next_beams("|", {pos, :u}, beams), do: [move(pos, :u) | beams]
  defp next_beams("|", {pos, :d}, beams), do: [move(pos, :d) | beams]
  defp next_beams("|", {pos, :l}, beams), do: [move(pos, :u), move(pos, :d) | beams]
  defp next_beams("|", {pos, :r}, beams), do: [move(pos, :u), move(pos, :d) | beams]

  defp run_beams(grid, beams, energized \\ %{})

  defp run_beams(_grid, [], energized),
    do: energized |> Map.keys() |> MapSet.new(&elem(&1, 0)) |> MapSet.size()

  defp run_beams(grid, [beam | beams], energized) when is_map_key(energized, beam) do
    run_beams(grid, beams, energized)
  end

  defp run_beams(grid, [{pos, _} | beams], energized) when not is_map_key(grid, pos) do
    run_beams(grid, beams, energized)
  end

  defp run_beams(grid, [{pos, _} = beam | beams], energized) do
    run_beams(grid, next_beams(grid[pos], beam, beams), Map.put(energized, beam, 1))
  end

  @doc ~S"""
      iex> sample() |> part_2()
      51

      iex> input() |> part_2()
      8148
  """
  def part_2(input) do
    grid = parse_input(input)
    keys = Map.keys(grid)
    {min_x, max_x} = keys |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = keys |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    from_top = Enum.map(min_x..max_x, &{{&1, min_y}, :d})
    from_bottom = Enum.map(min_x..max_x, &{{&1, max_y}, :u})
    from_left = Enum.map(min_y..max_y, &{{min_x, &1}, :r})
    from_right = Enum.map(min_y..max_y, &{{max_x, &1}, :l})

    Enum.concat([from_top, from_bottom, from_left, from_right])
    |> Stream.map(fn start -> run_beams(grid, [start]) end)
    |> Enum.max()
  end
end
