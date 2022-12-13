import AdventOfCode

solution 2022, 11 do
  @moduledoc """
  https://adventofcode.com/2022/day/11
  https://adventofcode.com/2022/day/11/input
  """

  def sample do
    """
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      10605

      iex> input() |> part_1()
      78960
  """
  def part_1(input) do
    input
    |> parse_input()
    |> Stream.iterate(&monkey_round(&1, fn val -> div(val, 3) end))
    |> Enum.at(20)
    |> monkey_business()
  end

  defp monkey_business(monkeys) do
    monkeys
    |> Map.values()
    |> Enum.map(&Map.get(&1, :inspected))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n", trim: true)
    |> Enum.into(%{}, &parse_monkey/1)
  end

  defp parse_monkey(monkey_input) do
    monkey_input
    |> String.split("\n", trim: true)
    |> Enum.reduce({nil, %{inspected: 0}}, &parse_monkey_line/2)
  end

  @monkey_number ~r/^Monkey (\d+):$/
  @starting_items ~r/^  Starting items: (.+)$/
  @operation ~r/^  Operation: new = old (\+|\*) (\d+|old)$/
  @test ~r/^  Test: divisible by (\d+)$/
  @if_true ~r/^    If true: throw to monkey (\d+)$/
  @if_false ~r/^    If false: throw to monkey (\d+)$/

  defp parse_monkey_line("Monkey " <> _ = line, {_, map}) do
    [_, number_string] = Regex.run(@monkey_number, line)
    number = String.to_integer(number_string)
    {number, map}
  end

  defp parse_monkey_line("  Starting items: " <> _ = line, {num, map}) do
    [_, items_string] = Regex.run(@starting_items, line)
    items = items_string |> String.split(", ") |> Enum.map(&String.to_integer/1)
    {num, Map.put(map, :items, items)}
  end

  defp parse_monkey_line("  Operation: " <> _ = line, {num, map}) do
    [_, operation_string, operand_string] = Regex.run(@operation, line)

    func =
      case {operation_string, operand_string} do
        {"+", "old"} -> &(&1 + &1)
        {"+", num} -> &(&1 + String.to_integer(num))
        {"*", "old"} -> &(&1 * &1)
        {"*", num} -> &(&1 * String.to_integer(num))
      end

    {num, Map.put(map, :operation, func)}
  end

  defp parse_monkey_line("  Test: " <> _ = line, {num, map}) do
    [_, divisible_by_string] = Regex.run(@test, line)
    divisible_by = String.to_integer(divisible_by_string)
    func = &(rem(&1, divisible_by) == 0)
    {num, map |> Map.put(:test?, func) |> Map.put(:divisible_by, divisible_by)}
  end

  defp parse_monkey_line("    If true: " <> _ = line, {num, map}) do
    [_, to] = Regex.run(@if_true, line)
    {num, Map.put(map, :if_true, String.to_integer(to))}
  end

  defp parse_monkey_line("    If false: " <> _ = line, {num, map}) do
    [_, to] = Regex.run(@if_false, line)
    {num, Map.put(map, :if_false, String.to_integer(to))}
  end

  defp monkey_round(monkeys, modify) do
    monkeys
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(monkeys, &monkey_turn(&1, &2, fn val -> modify.(val) end))
  end

  defp monkey_turn(num, monkeys, modify) do
    monkey = Map.get(monkeys, num)

    monkey.items
    |> Enum.map(fn item ->
      item |> monkey.operation.() |> modify.()
    end)
    |> Enum.split_with(&monkey.test?.(&1))
    |> then(fn {t, f} ->
      monkeys
      |> update_in([monkey.if_true, :items], &Enum.concat(&1, t))
      |> update_in([monkey.if_false, :items], &Enum.concat(&1, f))
      |> update_in([num, :inspected], &(&1 + length(monkey.items)))
      |> put_in([num, :items], [])
    end)
  end

  @doc ~S"""
      iex> sample() |> part_2()
      2713310158

      iex> input() |> part_2()
      14561971968
  """
  def part_2(input) do
    monkeys = parse_input(input)
    worry_modulus = find_worry_modulus(monkeys)

    monkeys
    |> Stream.iterate(&monkey_round(&1, fn val -> rem(val, worry_modulus) end))
    |> Enum.at(10000)
    |> monkey_business()
  end

  defp find_worry_modulus(monkeys) do
    monkeys
    |> Map.values()
    |> Enum.map(&Map.get(&1, :divisible_by))
    |> Enum.product()
  end
end
