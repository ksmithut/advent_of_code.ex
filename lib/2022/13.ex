import AdventOfCode

solution 2022, 13 do
  @moduledoc """
  https://adventofcode.com/2022/day/13
  https://adventofcode.com/2022/day/13/input
  """

  def sample do
    """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      13

      iex> input() |> part_1()
      6070
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.map(fn {[l, r], index} -> {right_order?(l, r), index} end)
    |> Enum.filter(&(elem(&1, 0) == true))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.flat_map(fn pair ->
      pair |> String.split("\n") |> Enum.map(&JSON.parse!/1)
    end)
  end

  defp right_order?([], [_b | _]), do: true
  defp right_order?([_a | _], []), do: false
  defp right_order?([a | a_rest], [a | b_rest]), do: right_order?(a_rest, b_rest)

  defp right_order?(a, b) when is_integer(a) and is_integer(b) and a < b, do: true
  defp right_order?(a, b) when is_integer(a) and is_integer(b) and a > b, do: false
  defp right_order?(a, a), do: nil

  defp right_order?(a, b) when not is_list(a) and is_list(b), do: right_order?([a], b)
  defp right_order?(a, b) when is_list(a) and not is_list(b), do: right_order?(a, [b])

  defp right_order?([a | a_rest], [b | b_rest]) do
    case right_order?(a, b) do
      nil -> right_order?(a_rest, b_rest)
      result -> result
    end
  end

  @doc ~S"""
      iex> sample() |> part_2()
      140

      iex> input() |> part_2()
      20758
  """

  def part_2(input) do
    div_packets = [[[2]], [[6]]]

    input
    |> parse_input()
    |> Enum.concat(div_packets)
    |> Enum.sort(&right_order?/2)
    |> Enum.with_index(1)
    |> Map.new()
    |> then(fn map ->
      div_packets
      |> Enum.map(&Map.get(map, &1))
      |> Enum.product()
    end)
  end
end
