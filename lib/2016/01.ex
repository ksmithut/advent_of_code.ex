import AdventOfCode

solution 2016, 1 do
  @moduledoc """
  https://adventofcode.com/2016/day/1
  https://adventofcode.com/2016/day/1/input
  """

  @doc ~S"""
      iex> "R2, L3" |> part_1()
      5

      iex> "R2, R2, R2" |> part_1()
      2

      iex> "R5, L5, R5, R3" |> part_1()
      12

      iex> input() |> part_1()
      234
  """
  def part_1(input) do
    input
    |> parse()
    |> Enum.reduce({{0, 0}, :north}, &move/2)
    |> elem(0)
    |> distance()
  end

  defp parse_command("R" <> num), do: {:right, String.to_integer(num)}
  defp parse_command("L" <> num), do: {:left, String.to_integer(num)}

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(", ", trim: true)
    |> Enum.map(&parse_command/1)
  end

  defp turn(:north, :right), do: :east
  defp turn(:east, :right), do: :south
  defp turn(:south, :right), do: :west
  defp turn(:west, :right), do: :north
  defp turn(:north, :left), do: :west
  defp turn(:west, :left), do: :south
  defp turn(:south, :left), do: :east
  defp turn(:east, :left), do: :north

  defp move({x, y}, :north, n), do: {x, y + n}
  defp move({x, y}, :east, n), do: {x + n, y}
  defp move({x, y}, :south, n), do: {x, y - n}
  defp move({x, y}, :west, n), do: {x - n, y}

  defp move({turn_direction, amount}, {position, direction}) do
    direction = turn(direction, turn_direction)
    {move(position, direction, amount), direction}
  end

  defp distance({x, y}), do: abs(x) + abs(y)

  @doc ~S"""
      iex> "R8, R4, R4, R8" |> part_2()
      4

      iex> input() |> part_2()
      113
  """
  def part_2(input) do
    input
    |> parse()
    |> Enum.reduce_while({{{0, 0}, :north}, MapSet.new([{0, 0}])}, &move_until_crossed/2)
    |> elem(0)
    |> elem(0)
    |> distance()
  end

  defp move_until_crossed(command, {position, visited}) do
    next = {next_position, direction} = move(command, position)
    {{x1, y1}, _} = position
    {x2, y2} = next_position
    [_ | positions] = for x <- x1..x2, y <- y1..y2, do: {x, y}

    positions
    |> Enum.find(&MapSet.member?(visited, &1))
    |> case do
      nil -> {:cont, {next, MapSet.union(visited, MapSet.new(positions))}}
      found -> {:halt, {{found, direction}, visited}}
    end
  end
end
