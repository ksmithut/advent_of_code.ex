import AdventOfCode

solution 2022, 15 do
  @moduledoc """
  https://adventofcode.com/2022/day/15
  https://adventofcode.com/2022/day/15/input
  """

  def sample do
    """
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """
  end

  @doc ~S"""
      iex> sample() |> part_1(10)
      26

      iex> input() |> part_1()
      4737567
  """
  def part_1(input, row \\ 2_000_000) do
    input
    |> parse_input()
    |> find_non_bomb_in_row(row)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @line_regex ~r/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/
  defp parse_line(line) do
    @line_regex
    |> Regex.run(line)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [sx, sy, bx, by] -> {{sx, sy}, {bx, by}, distance({sx, sy}, {bx, by})} end)
  end

  defp distance({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)

  defp find_non_bomb_in_row(input, row) do
    Enum.reduce(input, %{}, fn {{sx, sy} = sensor, {bx, by}, dist}, map ->
      y_range = (sy - dist)..(sy + dist)
      map = if by == row, do: Map.put(map, bx, :beacon), else: map

      if row in y_range do
        row_dist = distance(sensor, {sx, row})

        (sx - dist + row_dist)..(sx + dist - row_dist)
        |> Enum.reduce(map, &Map.put_new(&2, &1, :blank))
      else
        map
      end
    end)
    |> Enum.count(&(elem(&1, 1) == :blank))
  end

  @doc ~S"""
      iex> sample() |> part_2(20)
      56000011

      iex> input() |> part_2()
      13267474686239
  """
  def part_2(input, max_pos \\ 4_000_000) do
    sensors = parse_input(input)

    sensors
    |> Stream.flat_map(&perimeter_points/1)
    |> Stream.filter(fn {x, y} ->
      x >= 0 and y >= 0 and x <= max_pos and y <= max_pos
    end)
    |> Enum.find(fn pos ->
      Enum.all?(sensors, fn {sensor, _, dist} ->
        distance(sensor, pos) > dist
      end)
    end)
    |> then(fn {x, y} ->
      x * 4_000_000 + y
    end)
  end

  defp perimeter_points({{x, y}, _beacon, dist}) do
    min_x = x - dist - 1
    max_x = x + dist + 1
    min_y = y - dist - 1
    max_y = y + dist + 1

    [
      [min_x..x, y..min_y],
      [x..max_x, min_y..y],
      [max_x..x, y..max_y],
      [x..min_x, max_y..y]
    ]
    |> Stream.flat_map(&Stream.zip/1)
  end
end
