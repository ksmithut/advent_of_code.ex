defmodule Y2022.D17 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/17
  https://adventofcode.com/2022/day/17/input
  """

  def input, do: Path.join(["input", "2022", "17.txt"]) |> File.read!()

  def sample do
    """
    >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      3068

      iex> input() |> part_1()
      3239
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.cycle()
    |> Stream.scan(TetrisCavern.new(), &TetrisCavern.move(&2, &1))
    |> Enum.find(&(&1.rocks_placed === 2022))
    |> Map.get(:max_y)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.graphemes()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      1514285714288

      iex> input() |> part_2()
      1594842406882
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Stream.with_index()
    |> Stream.cycle()
    |> Stream.scan({TetrisCavern.new(), -1}, fn {dir, index}, {game, _prev} ->
      {TetrisCavern.move(game, dir), index}
    end)
    |> Stream.drop(1)
    |> Stream.map(fn {game, index} ->
      {game, hash_game(game, index)}
    end)
    |> Enum.reduce_while(%{}, fn
      {game, _}, {rounded_height, rocks_placed} when rocks_placed == game.rocks_placed ->
        {:halt, rounded_height + game.max_y}

      _, {_, _} = acc ->
        {:cont, acc}

      {game, {hash, _value}}, hash_map when is_map_key(hash_map, hash) ->
        {prev_rocks_placed, prev_max_y} = hash_map[hash]
        rocks_per_cycle = game.rocks_placed - prev_rocks_placed
        height_per_cycle = game.max_y - prev_max_y
        total_rocks = 1_000_000_000_000
        complete_cycles = div(total_rocks - game.rocks_placed, rocks_per_cycle)
        left = total_rocks - game.rocks_placed - rocks_per_cycle * complete_cycles
        {:cont, {height_per_cycle * complete_cycles, game.rocks_placed + left}}

      {_game, {hash, value}}, hash_map ->
        {:cont, Map.put(hash_map, hash, value)}
    end)
  end

  defp hash_game(game, index) do
    {{index, TetrisCavern.hash(game)}, {game.rocks_placed, game.max_y}}
  end
end

defmodule TetrisCavern do
  defstruct [:blocked, :rocks_placed, :shape, :rock, :max_y]

  @horizontal [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
  @plus [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}]
  @corner [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]
  @vertical [{0, 0}, {0, 1}, {0, 2}, {0, 3}]
  @square [{0, 0}, {1, 0}, {0, 1}, {1, 1}]

  def new() do
    blocked = Enum.into(0..6, MapSet.new(), &{&1, 0})

    %__MODULE__{
      blocked: blocked,
      rocks_placed: 0,
      max_y: get_max_y(blocked),
      shape: 0
    }
    |> add_rock()
  end

  defp rock_shape(0), do: @horizontal
  defp rock_shape(1), do: @plus
  defp rock_shape(2), do: @corner
  defp rock_shape(3), do: @vertical
  defp rock_shape(4), do: @square

  defp get_max_y(points), do: points |> Enum.map(&elem(&1, 1)) |> Enum.max()

  defp add_rock(%__MODULE__{max_y: max_y, shape: shape} = game) do
    %{game | rock: next_rock(rock_shape(shape), {2, max_y + 4}), shape: rem(shape + 1, 5)}
  end

  defp can_move?(%__MODULE__{blocked: blocked, rock: rock}, dir) do
    rock
    |> next_rock(dir)
    |> Enum.all?(fn {x, y} -> x in 0..6 and !MapSet.member?(blocked, {x, y}) end)
  end

  defp move_rock(%__MODULE__{rock: rock} = game, dir) do
    %{game | rock: next_rock(rock, dir)}
  end

  defp place_rock(%__MODULE__{rock: rock, rocks_placed: rocks_placed, blocked: blocked} = game) do
    %{
      game
      | blocked: Enum.into(rock, blocked),
        rocks_placed: rocks_placed + 1,
        max_y: max(get_max_y(rock), game.max_y)
    }
    |> add_rock()
  end

  defp next_rock(rock, {dx, dy}), do: Enum.map(rock, fn {x, y} -> {x + dx, y + dy} end)
  defp next_rock(rock, "<"), do: next_rock(rock, {-1, 0})
  defp next_rock(rock, ">"), do: next_rock(rock, {1, 0})
  defp next_rock(rock, "v"), do: next_rock(rock, {0, -1})

  def move(%__MODULE__{} = game, dir) do
    game = if can_move?(game, dir), do: move_rock(game, dir), else: game
    if can_move?(game, "v"), do: move_rock(game, "v"), else: place_rock(game)
  end

  def render(%__MODULE__{max_y: max_y, blocked: blocked, rock: rock}) do
    rock_set = MapSet.new(rock)

    (max_y + 6)..0
    |> Enum.map(fn y ->
      0..6
      |> Enum.map(fn x ->
        point = {x, y}

        cond do
          MapSet.member?(blocked, point) -> "#"
          MapSet.member?(rock_set, point) -> "@"
          true -> "."
        end
      end)
      |> Enum.join("")
      |> then(&("|" <> &1 <> "|"))
    end)
    |> Enum.join("\n")
    |> then(&(&1 <> "\n+-------+"))
  end

  def hash(%__MODULE__{} = game) do
    0..6
    |> Enum.map(fn x ->
      game.max_y..0
      |> Enum.find(fn y -> MapSet.member?(game.blocked, {x, y}) end)
      |> then(&Kernel.-(game.max_y, &1))
    end)
    |> then(&[game.shape | &1])
    |> List.to_tuple()
  end
end
