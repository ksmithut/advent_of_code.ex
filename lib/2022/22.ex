import AdventOfCode

solution 2022, 22 do
  @moduledoc """
  https://adventofcode.com/2022/day/22
  https://adventofcode.com/2022/day/22/input
  """

  def sample do
    """
            ...#
            .#..
            #...
            ....
    ...#.......#
    ........#...
    ..#....#....
    ..........#.
            ...#....
            .....#..
            .#......
            ......#.

    10R5L5R10L4R5L5
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      6032

      iex> input() |> part_1()
      60362
  """
  def part_1(input) do
    input
    |> parse_input()
    |> run()
    |> final_password()
  end

  defp final_password({{column, row}, dir}) do
    dir_score =
      case dir do
        :right -> 0
        :down -> 1
        :left -> 2
        :up -> 3
      end

    row * 1000 + column * 4 + dir_score
  end

  defp run({map, instructions}) do
    first_pos = {1, 1} |> next_across(:right, map) |> next_across(:down, map)
    run({first_pos, :right}, instructions, map)
  end

  defp run({pos, dir}, [], _map), do: {pos, dir}

  defp run({pos, dir}, [:right | instructions], map),
    do: run({pos, turn_right(dir)}, instructions, map)

  defp run({pos, dir}, [:left | instructions], map),
    do: run({pos, turn_left(dir)}, instructions, map)

  defp run({pos, dir}, [move | instructions], map) do
    1..move
    |> Enum.reduce_while({pos, dir}, fn _, {pos, dir} ->
      case map[pos][dir] do
        nil -> {:halt, {pos, dir}}
        {next_pos, next_dir} -> {:cont, {next_pos, next_dir}}
      end
    end)
    |> run(instructions, map)
  end

  defp parse_input(input) do
    [map_input, instructions_input] = input |> String.split("\n\n", trim: true)
    {parse_map(map_input), parse_instructions(instructions_input)}
  end

  defp parse_instructions(instructions_input) do
    instructions_input
    |> String.trim()
    |> String.graphemes()
    |> Enum.chunk_by(&Regex.match?(~r/\d/, &1))
    |> Enum.flat_map(fn [head | _] = items ->
      if head == "R" or head == "L" do
        Enum.map(items, fn
          "R" -> :right
          "L" -> :left
        end)
      else
        items |> Enum.join() |> String.to_integer() |> then(&[&1])
      end
    end)
  end

  def parse_map(map_input) do
    map =
      map_input
      |> String.split("\n", trim: true)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {line, y}, map ->
        line
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reduce(map, fn
          {" ", _x}, map -> map
          {".", x}, map -> Map.put(map, {x, y}, :blank)
          {"#", x}, map -> Map.put(map, {x, y}, :wall)
        end)
      end)

    map
    |> Enum.reduce(%{}, fn
      {_pos, :wall}, linked_map -> linked_map
      {pos, :blank}, linked_map -> Map.put(linked_map, pos, add_neighbors(pos, map))
    end)
  end

  defp add_neighbors(pos, map) do
    pos
    |> neighbors()
    |> Enum.reduce(%{}, fn {dir, neighbor}, neighbor_map ->
      case Map.get(map, neighbor) do
        :wall ->
          neighbor_map

        :blank ->
          Map.put(neighbor_map, dir, {neighbor, dir})

        nil ->
          next_pos_across = next_across(pos, dir, map)

          case map[next_pos_across] do
            :wall -> neighbor_map
            :blank -> Map.put(neighbor_map, dir, {next_pos_across, dir})
          end
      end
    end)
  end

  defp next_across({x, _y}, :up, map) do
    map
    |> Map.keys()
    |> Enum.filter(&(elem(&1, 0) == x))
    |> Enum.map(&elem(&1, 1))
    |> Enum.max()
    |> then(&{x, &1})
  end

  defp next_across({x, _y}, :down, map) do
    map
    |> Map.keys()
    |> Enum.filter(&(elem(&1, 0) == x))
    |> Enum.map(&elem(&1, 1))
    |> Enum.min()
    |> then(&{x, &1})
  end

  defp next_across({_x, y}, :left, map) do
    map
    |> Map.keys()
    |> Enum.filter(&(elem(&1, 1) == y))
    |> Enum.map(&elem(&1, 0))
    |> Enum.max()
    |> then(&{&1, y})
  end

  defp next_across({_x, y}, :right, map) do
    map
    |> Map.keys()
    |> Enum.filter(&(elem(&1, 1) == y))
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
    |> then(&{&1, y})
  end

  defp neighbors(pos) do
    [
      {:up, next(pos, :up)},
      {:right, next(pos, :right)},
      {:down, next(pos, :down)},
      {:left, next(pos, :left)}
    ]
  end

  defp turn_right(:up), do: :right
  defp turn_right(:right), do: :down
  defp turn_right(:down), do: :left
  defp turn_right(:left), do: :up

  defp turn_left(:up), do: :left
  defp turn_left(:left), do: :down
  defp turn_left(:down), do: :right
  defp turn_left(:right), do: :up

  defp next({x, y}, :up), do: {x, y - 1}
  defp next({x, y}, :right), do: {x + 1, y}
  defp next({x, y}, :down), do: {x, y + 1}
  defp next({x, y}, :left), do: {x - 1, y}

  @doc ~S"""
      # iex> sample() |> part_2()
      # 5031

      # iex> input() |> part_2()
      # input()
  """
  def part_2(input) do
    input
    |> parse_input_into_cube()
    |> run()
    |> final_password()
  end

  defp parse_input_into_cube(input) do
    [map, instructions] = input |> String.split("\n\n", trim: true)
    {parse_map_cube(map), parse_instructions(instructions)}
  end

  defp parse_map_cube(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {line, y}, map ->
        line
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reduce(map, fn
          {" ", _x}, map -> map
          {".", x}, map -> Map.put(map, {x, y}, :blank)
          {"#", x}, map -> Map.put(map, {x, y}, :wall)
        end)
      end)

    map
    |> Enum.reduce(%{}, fn
      {_pos, :wall}, linked_map -> linked_map
      {pos, :blank}, linked_map -> Map.put(linked_map, pos, add_neighbors_cubed(pos, map))
    end)
  end

  defp add_neighbors_cubed(pos, map) do
    pos
    |> neighbors()
    |> Enum.reduce(%{}, fn {dir, neighbor}, neighbor_map ->
      case Map.get(map, neighbor) do
        :wall ->
          neighbor_map

        :blank ->
          Map.put(neighbor_map, dir, {neighbor, dir})

        nil ->
          {next_pos_across, next_dir} = next_across_edge(pos, dir)

          case map[next_pos_across] do
            :wall -> neighbor_map
            :blank -> Map.put(neighbor_map, dir, {next_pos_across, next_dir})
          end
      end
    end)
  end

  defp next_across_edge({x, 101}, :up) when x in 1..50, do: {{51, x + 50}, :right}
  defp next_across_edge({x, 1}, :up) when x in 51..100, do: {{1, x + 100}, :right}
  defp next_across_edge({x, 1}, :up) when x in 101..150, do: {{x - 100, 200}, :up}

  defp next_across_edge({x, 200}, :down) when x in 1..50, do: {{x + 100, 1}, :down}
  defp next_across_edge({x, 150}, :down) when x in 51..100, do: {{50, x + 100}, :left}
  defp next_across_edge({x, 50}, :down) when x in 101..150, do: {{100, x - 50}, :left}

  defp next_across_edge({51, y}, :left) when y in 1..50, do: {{1, 151 - y}, :right}
  defp next_across_edge({51, y}, :left) when y in 51..100, do: {{y - 50, 101}, :down}
  defp next_across_edge({1, y}, :left) when y in 101..150, do: {{51, 151 - y}, :right}
  defp next_across_edge({1, y}, :left) when y in 151..200, do: {{y - 100, 1}, :down}

  defp next_across_edge({150, y}, :right) when y in 1..50, do: {{100, 151 - y}, :left}
  defp next_across_edge({100, y}, :right) when y in 51..100, do: {{y + 50, 50}, :up}
  defp next_across_edge({100, y}, :right) when y in 101..150, do: {{150, 151 - y}, :left}
  defp next_across_edge({50, y}, :right) when y in 151..200, do: {{y - 100, 150}, :up}
end
