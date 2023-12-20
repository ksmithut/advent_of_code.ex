defmodule Math do
  def prime_factors(number), do: prime_factors(number, 2, [])
  defp prime_factors(1, _, acc), do: acc |> Enum.reverse()
  defp prime_factors(n, d, acc) when rem(n, d) === 0, do: prime_factors(div(n, d), d, [d | acc])
  defp prime_factors(n, d, acc) when d + d > n, do: prime_factors(1, 1, [n | acc])
  defp prime_factors(n, 2, acc), do: prime_factors(n, 3, acc)
  defp prime_factors(n, d, acc), do: prime_factors(n, d + 2, acc)

  def least_common_multiple([_, _ | _] = numbers) do
    numbers
    |> Enum.map(&prime_factors/1)
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.reduce(%{}, fn freq, max_freq ->
      Enum.reduce(freq, max_freq, fn {factor, num}, max_freq ->
        max = Map.get(max_freq, factor, 0) |> max(num)
        Map.put(max_freq, factor, max)
      end)
    end)
    |> Enum.map(fn {factor, num} -> factor ** num end)
    |> Enum.product()
  end
end
