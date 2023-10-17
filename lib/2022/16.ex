import AdventOfCode

solution 2022, 16 do
  @moduledoc """
  https://adventofcode.com/2022/day/16
  https://adventofcode.com/2022/day/16/input
  """

  def sample do
    """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      1651

      iex> input() |> part_1()
      2114
  """
  def part_1(input) do
    valves = parse_input(input)
    graph = build_graph(valves)
    {distance_graph, _} = floyd_warshall(graph)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @line_regex ~r/^Valve (\w{2}) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/
  defp parse_line(line) do
    [_, valve, flow, to] = Regex.run(@line_regex, line)
    {valve, String.to_integer(flow), String.split(to, ", ")}
  end

  defp build_graph(valves) do
    Map.new(valves, fn {valve, _, to} -> {valve, Map.new(to, &{&1, 1})} end)
  end

  # https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
  defp floyd_warshall(graph) do
    vertices = Map.keys(graph)

    {dist, next} =
      Enum.reduce(graph, {%{}, %{}}, fn {a, to}, acc ->
        Enum.reduce(vertices, acc, fn
          ^a, {dist, next} ->
            {Map.put(dist, {a, a}, 0), Map.put(next, {a, a}, a)}

          b, {dist, next} when is_map_key(to, b) ->
            {Map.put(dist, {a, b}, to[b]), Map.put(next, {a, b}, b)}

          b, {dist, next} ->
            {Map.put_new(dist, {a, b}, :infinity), Map.put_new(next, {a, b}, nil)}
        end)
      end)

    Enum.reduce(vertices, {dist, next}, fn a, acc ->
      Enum.reduce(vertices, acc, fn b, acc ->
        Enum.reduce(vertices, acc, fn c, {dist, next} ->
          sum = add(dist[{b, a}], dist[{a, c}])

          if dist[{b, c}] > sum,
            do: {Map.put(dist, {b, c}, sum), Map.put(next, {b, c}, next[{b, a}])},
            else: {dist, next}
        end)
      end)
    end)
  end

  defp add(:infinity, _), do: :infinity
  defp add(_, :infinity), do: :infinity
  defp add(a, b), do: a + b

  @doc ~S"""
      iex> sample() |> part_2()
      1707

      iex> input() |> part_2()
      2666
  """
  def part_2(input) do
    input
  end
end
