import AdventOfCode

solution 2015, 11 do
  @moduledoc """
  https://adventofcode.com/2015/day/11
  https://adventofcode.com/2015/day/11/input
  """

  @doc ~S"""
      iex> "abcdefgh" |> part_1()
      "abcdffaa"

      iex> "ghijklmn" |> part_1()
      "ghjaabcc"

      iex> input() |> part_1()
      "hxbxxyzz"
  """
  def part_1(input) do
    input |> String.trim() |> next()
  end

  defp next(password) do
    password
    |> Stream.iterate(&increment/1)
    |> Enum.find(&valid?/1)
  end

  defp increment(value) when is_binary(value) do
    value
    |> String.to_charlist()
    |> Enum.reverse()
    |> increment()
    |> Enum.reverse()
    |> to_string()
  end

  defp increment([]), do: [?a]
  defp increment([?z | rest]), do: [?a | increment(rest)]
  defp increment([val | rest]) when val in [?i, ?o, ?l], do: [val + 1 | rest]
  defp increment([val | rest]), do: [val + 1 | rest]

  defp valid?(string) do
    has_straight?(string) and has_valid_chars?(string) and has_two_pairs?(string)
  end

  defp has_straight?(string) do
    string
    |> String.to_charlist()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn [a, b, c] ->
      a + 1 == b and a + 2 == c
    end)
  end

  defp has_valid_chars?(string), do: !String.match?(string, ~r/[iol]/)

  defp has_two_pairs?(string) do
    Regex.scan(~r/(.)\1/, string)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.uniq()
    |> length()
    |> Kernel.>=(2)
  end

  @doc ~S"""
      iex> "" |> part_2()
      ""

      iex> input() |> part_2()
      input()
  """
  def part_2(input) do
    input
  end
end
