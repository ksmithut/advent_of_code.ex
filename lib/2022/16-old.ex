import AdventOfCode

solution 2022, 160 do
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
    data = parse_input(input)
    nodes = for d <- data, d.flow > 0 or length(d.destinations) != 2, do: d.source
    data_by_source = Map.new(data, &{&1.source, &1})
    flows = for d <- data, into: %{}, do: {d.source, d.flow}

    follow = fn node, next ->
      [next, node]
      |> Stream.iterate(fn [h | t] ->
        if h not in nodes, do: [hd(data_by_source[h].destinations -- t), h | t]
      end)
      |> Enum.take_while(& &1)
      |> List.last()
    end

    lengths =
      for node <- nodes, dest <- data_by_source[node].destinations, into: %{} do
        path = follow.(node, dest)
        {[node, hd(path)], length(path) - 1}
      end

    fill_in_distances = fn known_distances ->
      new_pairs =
        for {p, dp} <- known_distances,
            {q, dq} <- known_distances,
            p != q,
            MapSet.intersection(p, q) |> MapSet.size() == 1,
            pq = MapSet.difference(MapSet.union(p, q), MapSet.intersection(p, q)),
            not is_map_key(known_distances, pq),
            do: {pq, dp + dq}

      best_computed_distances =
        new_pairs
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Map.new(fn {p, ds} -> {p, Enum.min(ds)} end)

      Map.merge(known_distances, best_computed_distances)
    end

    initial = for {p, d} <- lengths, into: %{}, do: {MapSet.new(p), d}

    all_distances =
      initial
      |> then(fill_in_distances)
      |> then(fill_in_distances)
      |> then(fill_in_distances)

    all_distances_from =
      all_distances
      |> Enum.flat_map(fn {pair, d} ->
        [p, q] = Enum.to_list(pair)
        [{p, q, d}, {q, p, d}]
      end)
      |> Enum.reduce(%{}, fn {p, q, d}, acc ->
        Map.update(acc, p, %{q => d}, &Map.put(&1, q, d))
      end)

    paths = fn max_time ->
      initial = %{p: ["AA"], t: max_time, flow: 0, total: 0}
      queue = :queue.new()
      queue = :queue.in(initial, queue)

      Stream.resource(
        fn -> queue end,
        fn queue ->
          case :queue.out(queue) do
            {:empty, _} ->
              {:halt, nil}

            {{:value, current}, next} ->
              %{p: [h | t], t: time} = current

              opened = %{
                current
                | t: time - 1,
                  flow: current.flow + flows[h],
                  total: current.total + current.flow
              }

              next_paths =
                for {q, d} <- all_distances_from[h], d < time, q not in t do
                  new_p = [q, h | t]
                  new_t = opened.t - d
                  %{opened | p: new_p, t: new_t, total: opened.total + d * opened.flow}
                end

              new_flow = opened.flow + flows[hd(opened.p)]
              new_total = opened.total + (opened.t + 1) * opened.flow
              finished = %{opened | flow: new_flow, total: new_total}

              {[finished], Enum.reduce(next_paths, next, &:queue.in/2)}
          end
        end,
        & &1
      )
    end

    paths.(30)
    |> Enum.max_by(& &1.total)
    |> Map.get(:total)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @line_regex ~r/^Valve (\w{2}) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/
  defp parse_line(line) do
    [_, source, flow, to | _rest] = Regex.run(@line_regex, line)
    %{source: source, flow: String.to_integer(flow), destinations: to |> String.split(", ")}
  end

  @doc ~S"""
      iex> sample() |> part_2()
      1707

      iex> input() |> part_2()
      2666
  """
  def part_2(input) do
    data = parse_input(input)
    nodes = for d <- data, d.flow > 0 or length(d.destinations) != 2, do: d.source
    data_by_source = Map.new(data, &{&1.source, &1})
    flows = for d <- data, into: %{}, do: {d.source, d.flow}

    follow = fn node, next ->
      [next, node]
      |> Stream.iterate(fn [h | t] ->
        if h not in nodes, do: [hd(data_by_source[h].destinations -- t), h | t]
      end)
      |> Enum.take_while(& &1)
      |> List.last()
    end

    lengths =
      for node <- nodes, dest <- data_by_source[node].destinations, into: %{} do
        path = follow.(node, dest)
        {[node, hd(path)], length(path) - 1}
      end

    fill_in_distances = fn known_distances ->
      new_pairs =
        for {p, dp} <- known_distances,
            {q, dq} <- known_distances,
            p != q,
            MapSet.intersection(p, q) |> MapSet.size() == 1,
            pq = MapSet.difference(MapSet.union(p, q), MapSet.intersection(p, q)),
            not is_map_key(known_distances, pq),
            do: {pq, dp + dq}

      best_computed_distances =
        new_pairs
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Map.new(fn {p, ds} -> {p, Enum.min(ds)} end)

      Map.merge(known_distances, best_computed_distances)
    end

    initial = for {p, d} <- lengths, into: %{}, do: {MapSet.new(p), d}

    all_distances =
      initial
      |> then(fill_in_distances)
      |> then(fill_in_distances)
      |> then(fill_in_distances)

    all_distances_from =
      all_distances
      |> Enum.flat_map(fn {pair, d} ->
        [p, q] = Enum.to_list(pair)
        [{p, q, d}, {q, p, d}]
      end)
      |> Enum.reduce(%{}, fn {p, q, d}, acc ->
        Map.update(acc, p, %{q => d}, &Map.put(&1, q, d))
      end)

    paths = fn max_time ->
      initial = %{p: ["AA"], t: max_time, flow: 0, total: 0}
      queue = :queue.new()
      queue = :queue.in(initial, queue)

      Stream.resource(
        fn -> queue end,
        fn queue ->
          case :queue.out(queue) do
            {:empty, _} ->
              {:halt, nil}

            {{:value, current}, next} ->
              %{p: [h | t], t: time} = current

              opened = %{
                current
                | t: time - 1,
                  flow: current.flow + flows[h],
                  total: current.total + current.flow
              }

              next_paths =
                for {q, d} <- all_distances_from[h], d < time, q not in t do
                  new_p = [q, h | t]
                  new_t = opened.t - d
                  %{opened | p: new_p, t: new_t, total: opened.total + d * opened.flow}
                end

              new_flow = opened.flow + flows[hd(opened.p)]
              new_total = opened.total + (opened.t + 1) * opened.flow
              finished = %{opened | flow: new_flow, total: new_total}

              {[finished], Enum.reduce(next_paths, next, &:queue.in/2)}
          end
        end,
        & &1
      )
    end

    p26 =
      paths.(26)
      |> Enum.reduce(%{}, fn x, acc ->
        Map.update(acc, MapSet.new(x.p -- ["AA"]), x.total, &max(&1, x.total))
      end)

    best_strategy_for_part_1 = part_1(input)

    Enum.max(
      for {p, c} <- p26,
          {ep, ec} <- p26,
          c + ec > best_strategy_for_part_1,
          MapSet.disjoint?(p, ep),
          do: c + ec
    )
  end
end
