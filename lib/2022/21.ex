import AdventOfCode

solution 2022, 21 do
  @moduledoc """
  https://adventofcode.com/2022/day/21
  https://adventofcode.com/2022/day/21/input
  """

  def sample do
    """
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      152

      iex> input() |> part_1()
      66174565793494
  """
  def part_1(input) do
    input
    |> parse_input()
    |> simplify()
    |> elem(1)
    |> Map.get("root")
  end

  @line_regex ~r/^(\w+): ((\d+)|(\w+) (\+|\*|\/|-) (\w+))$/

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.into(%{}, fn line ->
      case Regex.run(@line_regex, line) do
        [_, key, _, _, l, op, r] -> {key, {op, op(op), l, r}}
        [_, key, _, num] -> {key, String.to_integer(num)}
      end
    end)
  end

  defp op("+"), do: &Kernel.+/2
  defp op("-"), do: &Kernel.-/2
  defp op("*"), do: &Kernel.*/2
  defp op("/"), do: &div/2
  defp op("="), do: &Kernel.==/2

  defp simplify(equations, resolved \\ %{}) do
    equations
    |> Enum.reduce({%{}, resolved}, fn
      {monkey, value}, {equations, resolved} when is_integer(value) ->
        {equations, Map.put(resolved, monkey, value)}

      {monkey, {_sign, op, l, r}}, {equations, resolved} when is_integer(l) and is_integer(r) ->
        {equations, Map.put(resolved, monkey, op.(l, r))}

      {monkey, {sign, op, l, r}}, {equations, resolved} when is_map_key(resolved, l) ->
        {Map.put(equations, monkey, {sign, op, resolved[l], r}), resolved}

      {monkey, {sign, op, l, r}}, {equations, resolved} when is_map_key(resolved, r) ->
        {Map.put(equations, monkey, {sign, op, l, resolved[r]}), resolved}

      {monkey, value}, {equations, resolved} ->
        {Map.put(equations, monkey, value), resolved}
    end)
    |> case do
      {^equations, _resolved} -> {equations, resolved}
      {equations, resolved} -> simplify(equations, resolved)
    end
  end

  @doc ~S"""
      iex> sample() |> part_2()
      301

      iex> input() |> part_2()
      3327575724809
  """
  def part_2(input) do
    input
    |> parse_input()
    |> Map.update!("root", fn {_, _, left, right} -> {"=", op("="), left, right} end)
    |> Map.put("humn", :variable)
    |> simplify()
    |> elem(0)
    |> solve()
  end

  defp solve(equations) do
    case equations["root"] do
      {"=", _, left, right} when is_integer(left) -> {right, left}
      {"=", _, left, right} when is_integer(right) -> {left, right}
    end
    |> solve_for(equations)
  end

  defp solve_for({"humn", value}, _equations), do: value

  defp solve_for({monkey, value}, equations) do
    case equations[monkey] do
      {"+", _, l, r} when is_integer(l) -> {r, value - l}
      {"+", _, l, r} when is_integer(r) -> {l, value - r}
      {"-", _, l, r} when is_integer(l) -> {r, -(value - l)}
      {"-", _, l, r} when is_integer(r) -> {l, value + r}
      {"*", _, l, r} when is_integer(l) -> {r, div(value, l)}
      {"*", _, l, r} when is_integer(r) -> {l, div(value, r)}
      {"/", _, l, r} when is_integer(l) -> {r, div(l, value)}
      {"/", _, l, r} when is_integer(r) -> {l, value * r}
    end
    |> solve_for(equations)
  end
end
