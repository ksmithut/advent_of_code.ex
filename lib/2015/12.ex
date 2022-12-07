import AdventOfCode

solution 2015, 12 do
  @moduledoc """
  https://adventofcode.com/2015/day/12
  https://adventofcode.com/2015/day/12/input
  """

  @doc ~S"""
      iex> ~s([1,2,3]) |> part_1()
      6

      iex> ~s({"a":2,"b":4}) |> part_1()
      6

      iex> ~s([[[3]]]) |> part_1()
      3

      iex> ~s({"a":{"b":4},"c":-1}) |> part_1()
      3

      iex> ~s({"a":[-1,1]}) |> part_1()
      0

      iex> ~s([-1,{"a":1}]) |> part_1()
      0

      iex> ~s([]) |> part_1()
      0

      iex> ~s({}) |> part_1()
      0

      iex> input() |> part_1()
      111754
  """
  def part_1(input) do
    input
    |> JSON.parse!()
    |> reduce_deep(0, fn val, total ->
      cond do
        is_integer(val) -> {:cont, total + val}
        true -> {:cont, total}
      end
    end)
  end

  defp reduce_deep(value, acc, reducer) do
    do_reduce_deep([value], acc, reducer)
  end

  defp do_reduce_deep([], acc, _reducer), do: acc

  defp do_reduce_deep([item | queue], acc, reducer) do
    {queue, acc} =
      case reducer.(item, acc) do
        {:halt, acc} -> {queue, acc}
        {:cont, acc} when is_list(item) -> {Enum.concat(item, queue), acc}
        {:cont, acc} when is_map(item) -> {Enum.concat(Map.values(item), queue), acc}
        {:cont, acc} -> {queue, acc}
      end

    do_reduce_deep(queue, acc, reducer)
  end

  @doc ~S"""
      iex> ~s([1,2,3]) |> part_2()
      6

      iex> ~s([1,{"c":"red","b":2},3]) |> part_2()
      4

      iex> ~s({"d":"red","e":[1,2,3,4],"f":5}) |> part_2()
      0

      iex> ~s([1,"red",5]) |> part_2()
      6

      iex> input() |> part_2()
      65402
  """
  def part_2(input) do
    input
    |> JSON.parse!()
    |> reduce_deep(0, fn val, total ->
      cond do
        is_map(val) and "red" in Map.values(val) -> {:halt, total}
        is_integer(val) -> {:cont, total + val}
        true -> {:cont, total}
      end
    end)
  end
end
