defmodule Y2022.D09 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/9
  https://adventofcode.com/2022/day/9/input
  """

  def input, do: Path.join(["input", "2022", "09.txt"]) |> File.read!()

  def sample do
    """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
  end

  def sample_2 do
    """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      13

      iex> input() |> part_1()
      6067
  """
  def part_1(input) do
    input
    |> parse_input()
    |> run_rope(2)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, amount] = String.split(line)
      {dir, String.to_integer(amount)}
    end)
  end

  defp run_rope(instructions, length) do
    rope = 1..length |> Enum.map(fn _ -> {0, 0} end)

    instructions
    |> Enum.reduce({MapSet.new([{0, 0}]), rope}, fn {dir, num}, acc ->
      Enum.reduce(1..num, acc, fn _, {visited, [head | tail]} ->
        head = move(dir, head)
        {last, rope} = move_rope(tail, head, [head])
        {MapSet.put(visited, last), rope}
      end)
    end)
    |> elem(0)
    |> MapSet.size()
  end

  defp move_rope([], prev, acc), do: {prev, Enum.reverse(acc)}

  defp move_rope([head | tail], prev, acc) do
    head = follow(prev, head)
    move_rope(tail, head, [head | acc])
  end

  defp move("R", {x, y}), do: {x + 1, y}
  defp move("D", {x, y}), do: {x, y + 1}
  defp move("L", {x, y}), do: {x - 1, y}
  defp move("U", {x, y}), do: {x, y - 1}

  defp follow({hx, hy}, {tx, ty}) when (hx - tx) in -1..1 and (hy - ty) in -1..1, do: {tx, ty}
  defp follow({hx, hy}, {tx, ty}), do: {inc_to(hx, tx), inc_to(hy, ty)}

  defp inc_to(h, h), do: h
  defp inc_to(h, t) when h > t, do: t + 1
  defp inc_to(h, t) when h < t, do: t - 1

  @doc ~S"""
      iex> sample() |> part_2()
      1

      iex> sample_2() |> part_2()
      36

      iex> input() |> part_2()
      2471
  """
  def part_2(input) do
    input
    |> parse_input()
    |> run_rope(10)
  end
end
