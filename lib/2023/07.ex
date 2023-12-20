defmodule Y2023.D07 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/7
  https://adventofcode.com/2023/day/7/input
  """

  def input, do: Path.join(["input", "2023", "07.txt"]) |> File.read!()

  def sample do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      [hand, bid] = String.split(line)
      hand = hand |> String.graphemes() |> Enum.map(&parse_card/1)
      {hand, String.to_integer(bid)}
    end)
  end

  defp parse_card("A"), do: 14
  defp parse_card("K"), do: 13
  defp parse_card("Q"), do: 12
  defp parse_card("J"), do: 11
  defp parse_card("T"), do: 10
  defp parse_card(num), do: String.to_integer(num)

  # five-of-a-kind
  defp score([a, a, a, a, a]), do: 6
  # four-of-a-kind
  defp score([a, a, a, a, _]), do: 5
  defp score([_, a, a, a, a]), do: 5
  # full-house
  defp score([a, a, a, b, b]), do: 4
  defp score([b, b, a, a, a]), do: 4
  # three-of-a-kind
  defp score([a, a, a, _, _]), do: 3
  defp score([_, a, a, a, _]), do: 3
  defp score([_, _, a, a, a]), do: 3
  # two-pair
  defp score([a, a, b, b, _]), do: 2
  defp score([a, a, _, b, b]), do: 2
  defp score([_, a, a, b, b]), do: 2
  # one-pair
  defp score([a, a, _, _, _]), do: 1
  defp score([_, a, a, _, _]), do: 1
  defp score([_, _, a, a, _]), do: 1
  defp score([_, _, _, a, a]), do: 1
  # high
  defp score(_), do: 0

  defp sort_hands({a, _, score}, {b, _, score}), do: a < b
  defp sort_hands({_, _, a}, {_, _, b}), do: a < b

  defp winnings(hands) do
    hands
    |> Enum.sort(&sort_hands/2)
    |> Stream.map(&elem(&1, 1))
    |> Stream.with_index(1)
    |> Stream.map(fn {bid, index} -> bid * index end)
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_1()
      6440

      iex> input() |> part_1()
      251927063
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.map(fn {hand, bid} -> {hand, bid, hand |> Enum.sort() |> score()} end)
    |> winnings()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      5905

      iex> input() |> part_2()
      255632664
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Stream.map(fn {hand, bid} ->
      {replace_wild(hand), bid, hand |> Enum.sort() |> score_wild()}
    end)
    |> winnings()
  end

  defp replace_wild(hand), do: Enum.map(hand, &if(&1 == 11, do: 1, else: &1))

  defp score_wild(hand) do
    hand
    |> Enum.map(&if(&1 == 11, do: 2..14, else: &1))
    |> expand([[]])
    |> Stream.map(&(&1 |> Enum.sort() |> score()))
    |> Enum.max()
  end

  defp expand([], acc), do: acc
  defp expand([_.._ = r | rest], acc), do: expand(rest, Enum.flat_map(r, &append_acc(&1, acc)))
  defp expand([num | rest], acc), do: expand(rest, append_acc(num, acc))
  defp append_acc(num, acc), do: Enum.map(acc, &[num | &1])
end
