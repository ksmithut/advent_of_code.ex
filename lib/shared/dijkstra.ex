defmodule Dijkstra do
  def graph(graph, source) do
    {dist, prev, queue} =
      Enum.reduce(graph, {%{}, %{}, []}, fn {vertex, _}, {dist, prev, queue} ->
        {Map.put(dist, vertex, :infinity), Map.put(prev, vertex, nil), [vertex | queue]}
      end)

    run_queue(queue, graph, Map.put(dist, source, 0), prev)
  end

  defp run_queue([], _graph, dist, _prev), do: dist

  defp run_queue(queue, graph, dist, prev) do
    curr = queue |> Enum.min_by(&Map.get(dist, &1))
    queue = List.delete(queue, curr)

    {dist, prev} =
      curr
      |> neighbors()
      |> Enum.filter(&Map.has_key?(dist, &1))
      |> Enum.reduce({dist, prev}, fn v, {dist, prev} ->
        alt = add(dist[curr], graph[curr][v])

        if alt < dist[v],
          do: {Map.put(dist, v, alt), Map.put(prev, v, curr)},
          else: {dist, prev}
      end)

    run_queue(queue, graph, dist, prev)
  end

  defp neighbors({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  defp add(:infinity, _b), do: :infinity
  defp add(_a, :infinity), do: :infinity
  defp add(a, b), do: a + b
end
