defmodule Y2022.D23 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/23
  https://adventofcode.com/2022/day/23/input
  """

  def input, do: Path.join(["input", "2022", "23.txt"]) |> File.read!()

  def sample do
    """
    ....#..
    ..###.#
    #...#.#
    .#...##
    #.###..
    ##.#.##
    .#..#..
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      110

      # iex> input() |> part_1()
      # input()
  """
  def part_1(input, rounds \\ 10) do
    input
    |> parse_input()
    |> rounds(rounds)
    |> area()
  end

  defp area(elves) do
    {min_x, max_x} = elves |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = elves |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    (max_y - min_y + 1) * (max_x - min_x + 1) - MapSet.size(elves)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, elves ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(elves, fn
        {".", _x}, elves -> elves
        {"#", x}, elves -> MapSet.put(elves, {x, y})
      end)
    end)
  end

  @directions [:n, :s, :w, :e, :nw, :ne, :sw, :se]

  defp neighbors(pos), do: Enum.into(@directions, %{}, &{&1, next(pos, &1)})

  defp next({x, y}, :n), do: {x, y - 1}
  defp next({x, y}, :s), do: {x, y + 1}
  defp next({x, y}, :w), do: {x - 1, y}
  defp next({x, y}, :e), do: {x + 1, y}
  defp next(pos, :nw), do: pos |> next(:n) |> next(:w)
  defp next(pos, :ne), do: pos |> next(:n) |> next(:e)
  defp next(pos, :sw), do: pos |> next(:s) |> next(:w)
  defp next(pos, :se), do: pos |> next(:s) |> next(:e)

  @moves [[:n, :ne, :nw], [:s, :se, :sw], [:w, :nw, :sw], [:e, :ne, :se]]

  defp rounds(elves, times) do
    rounds(elves, @moves, times)
  end

  defp rounds(elves, _, 0), do: elves

  defp rounds(elves, [first | rest] = moves, times) do
    elves |> round(moves) |> rounds(rest ++ [first], times - 1)
  end

  defp round(elves, moves) do
    elves
    |> Enum.reduce(%{}, fn elf, proposed ->
      adj = neighbors(elf)
      alone? = adj |> Enum.map(&elem(&1, 1)) |> Enum.all?(&(not MapSet.member?(elves, &1)))

      if alone? do
        proposed
      else
        moves
        |> Enum.find(fn dirs ->
          Enum.all?(dirs, fn dir -> not MapSet.member?(elves, adj[dir]) end)
        end)
        |> case do
          nil -> proposed
          [dir, _, _] -> Map.update(proposed, adj[dir], [elf], &[elf | &1])
        end
      end
    end)
    |> Enum.filter(fn {_to, from} -> length(from) == 1 end)
    |> Enum.reduce(elves, fn {to, [from]}, elves ->
      elves |> MapSet.delete(from) |> MapSet.put(to)
    end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      20

      # iex> input() |> part_2()
      # input()
  """
  def part_2(input) do
    input
    |> parse_input()
    |> run()
  end

  defp run(elves) do
    @moves
    |> Stream.iterate(fn [first | rest] -> rest ++ [first] end)
    |> Enum.reduce_while({elves, 1}, fn moves, {elves, count} ->
      case round(elves, moves) do
        ^elves -> {:halt, count}
        elves -> {:cont, {elves, count + 1}}
      end
    end)
  end
end
