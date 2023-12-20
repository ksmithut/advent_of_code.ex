defmodule Memoize do
  use Agent

  def start_link(func) do
    Agent.start_link(fn -> {%{}, func} end)
  end

  def create(func) do
    {:ok, pid} = __MODULE__.start_link(func)
    &__MODULE__.call(pid, &1)
  end

  def call(pid, arg) do
    Agent.get(pid, fn
      {cache, _} when is_map_key(cache, arg) -> {:hit, cache[arg]}
      {_, func} -> {:miss, func}
    end)
    |> case do
      {:miss, func} ->
        value = func.(arg, &Memoize.call(pid, &1))
        Agent.update(pid, fn {cache, func} -> {Map.put(cache, arg, value), func} end)
        value

      {:hit, value} ->
        value
    end
  end
end
