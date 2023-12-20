defmodule Y2023.D19 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/19
  https://adventofcode.com/2023/day/19/input
  """

  def input, do: Path.join(["input", "2023", "19.txt"]) |> File.read!()

  def sample do
    """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """
  end

  defp parse_input(input) do
    [workflows, parts] = input |> String.split("\n\n", trim: true) |> Enum.map(&String.split/1)
    {Map.new(workflows, &parse_workflow/1), Enum.map(parts, &parse_part/1)}
  end

  @workflow_regex ~r/^(\w+){(.*)}$/
  defp parse_workflow(workflow) do
    [_, name, body] = Regex.run(@workflow_regex, workflow)
    {name, body |> String.split(",") |> Enum.map(&parse_statement/1)}
  end

  @compare_regex ~r/^([xmas])([<>])(\d+):(\w+)/
  defp parse_statement(statement) do
    cond do
      Regex.match?(@compare_regex, statement) ->
        [_, key, op, value, target] = Regex.run(@compare_regex, statement)
        {:compare, key, op, String.to_integer(value), get_target(target)}

      true ->
        {:result, get_target(statement)}
    end
  end

  defp get_target("A"), do: :accept
  defp get_target("R"), do: :reject
  defp get_target(key), do: {:target, key}

  @part_regex ~r/^{(.*)}$/
  defp parse_part(part) do
    [_, part] = Regex.run(@part_regex, part)

    part
    |> String.split(",")
    |> Map.new(fn prop ->
      [key, value] = String.split(prop, "=")
      {key, String.to_integer(value)}
    end)
  end

  @doc ~S"""
      iex> sample() |> part_1()
      19114

      iex> input() |> part_1()
      446935
  """
  def part_1(input) do
    {workflows, parts} = parse_input(input)

    workflows =
      Map.new(workflows, fn {key, statements} ->
        {key,
         fn map ->
           Enum.find_value(statements, fn
             {:result, target} -> target
             {:compare, key, "<", value, target} -> if map[key] < value, do: target
             {:compare, key, ">", value, target} -> if map[key] > value, do: target
           end)
         end}
      end)

    parts
    |> Stream.filter(&run(&1, workflows))
    |> Stream.map(&sum_part/1)
    |> Enum.sum()
  end

  defp run(part, workflow, target \\ {:target, "in"})
  defp run(_part, _workflows, :reject), do: false
  defp run(_part, _workflows, :accept), do: true
  defp run(part, workflows, {:target, key}), do: run(part, workflows, workflows[key].(part))

  defp sum_part(part), do: Map.values(part) |> Enum.sum()

  @doc ~S"""
      iex> sample() |> part_2()
      167409079868000

      iex> input() |> part_2()
      141882534122898
  """
  def part_2(input) do
    input
    |> parse_input()
    |> elem(0)
    |> get_ranges()
    |> Stream.map(&sum_range/1)
    |> Enum.sum()
  end

  @initial_range %{"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}
  def get_ranges(workflows, target \\ {:target, "in"}, range \\ @initial_range)
  def get_ranges(_workflows, :reject, _), do: []
  def get_ranges(_workflows, :accept, range), do: [range]

  def get_ranges(workflows, {:target, name}, range) do
    workflows[name]
    |> Enum.flat_map_reduce(range, fn
      {:result, target}, range ->
        {get_ranges(workflows, target, range), range}

      {:compare, rating, "<", value, target}, range ->
        sub_range = put_in(range[rating].last, value - 1)
        range = put_in(range[rating].first, value)
        {get_ranges(workflows, target, sub_range), range}

      {:compare, rating, ">", value, target}, range ->
        sub_range = put_in(range[rating].first, value + 1)
        range = put_in(range[rating].last, value)
        {get_ranges(workflows, target, sub_range), range}
    end)
    |> elem(0)
  end

  defp sum_range(range), do: range |> Map.values() |> Enum.map(&Range.size/1) |> Enum.product()
end
