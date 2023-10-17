import AdventOfCode

solution 2022, 19 do
  @moduledoc """
  https://adventofcode.com/2022/day/19
  https://adventofcode.com/2022/day/19/input
  """

  def sample do
    """
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      33

      # iex> input() |> part_1()
      # 851
  """
  def part_1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Blueprint.new/1)
    |> Task.async_stream(
      fn blueprint ->
        blueprint.costs
        |> Operation.new()
        |> Operation.max_geodes(24)
        |> Kernel.*(blueprint.number)
      end,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, value} -> value end)
    |> Enum.sum()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      3472

      # iex> input() |> part_2()
      # 12160
  """
  def part_2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.take(3)
    |> Enum.map(&Blueprint.new/1)
    |> Task.async_stream(
      fn blueprint ->
        blueprint.costs
        |> Operation.new()
        |> Operation.max_geodes(32)
      end,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, value} -> value end)
    |> Enum.product()
  end
end

defmodule Blueprint do
  defstruct [:number, :costs]

  @type resource :: :ore | :clay | :obsidian | :geode
  @type costs :: %{resource() => %{resource() => non_neg_integer()}}
  @type t :: %__MODULE__{number: non_neg_integer(), costs: costs()}

  @spec new(binary()) :: Blueprint.t()
  def new(line) do
    Regex.scan(~r/\d+/, line)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [number, ore_ore, clay_ore, obs_ore, obs_clay, geo_ore, geo_ob] ->
      %__MODULE__{
        number: number,
        costs: %{
          ore: %{ore: ore_ore},
          clay: %{ore: clay_ore},
          obsidian: %{ore: obs_ore, clay: obs_clay},
          geode: %{ore: geo_ore, obsidian: geo_ob}
        }
      }
    end)
  end
end

defmodule Operation do
  defstruct [:robots, :resources, :costs]

  @type resource_map :: %{Blueprint.resource() => non_neg_integer()}
  @type t :: %__MODULE__{
          robots: resource_map(),
          resources: resource_map(),
          costs: Blueprint.costs()
        }

  @initial_robots %{ore: 1, clay: 0, obsidian: 0, geode: 0}
  @initial_resources %{ore: 0, clay: 0, obsidian: 0, geode: 0}

  @spec new(costs :: Blueprint.costs()) :: t()
  def new(costs) do
    %__MODULE__{robots: @initial_robots, resources: @initial_resources, costs: costs}
  end

  def max_geodes(%__MODULE__{} = operation, time) do
    work(0, operation, time)
  end

  defp work(max, operation, 0) do
    do_work(max, nil, operation, 0)
  end

  defp work(max, operation, time) do
    max
    |> do_work(:geode, operation, time)
    |> do_work(:obsidian, operation, time)
    |> do_work(:clay, operation, time)
    |> do_work(:ore, operation, time)
    |> do_work(nil, operation, time)
  end

  defp do_work(max, nil, op, time), do: max(max, op.resources.geode + op.robots.geode * time)

  defp do_work(max, :geode, op, time)
       when op.robots.obsidian * (time - 2) + op.resources.obsidian < op.costs.geode.obsidian or
              op.robots.ore * (time - 2) + op.resources.ore < op.costs.geode.ore,
       do: max

  defp do_work(max, :obsidian, op, time)
       when op.robots.clay * (time - 2) + op.resources.clay < op.costs.obsidian.clay or
              op.robots.ore * (time - 2) + op.resources.ore < op.costs.obsidian.ore or
              op.robots.obsidian >= op.costs.geode.obsidian,
       do: max

  defp do_work(max, :clay, op, time)
       when op.robots.ore * (time - 2) + op.resources.ore < op.costs.clay.ore or
              op.robots.clay >= op.costs.obsidian.clay,
       do: max

  defp do_work(max, :ore, op, time)
       when op.robots.ore * (time - 2) + op.resources.ore < op.costs.ore.ore or
              (op.robots.ore >= op.costs.clay.ore and op.robots.ore >= op.costs.obsidian.ore and
                 op.robots.ore >= op.costs.geode.ore),
       do: max

  defp do_work(max, type, op, time) do
    time_needed =
      op.costs[type]
      |> Enum.reduce(0, fn {cost_type, cost}, time_needed ->
        resources = op.resources[cost_type]
        bots = op.robots[cost_type]
        max(time_needed, div(cost - resources + bots - 1, bots))
      end)
      |> Kernel.+(1)

    resources =
      Enum.into(op.resources, %{}, fn {resource_type, amount} ->
        cost = op.costs[type][resource_type] || 0
        bots = op.robots[resource_type]
        {resource_type, amount + time_needed * bots - cost}
      end)

    robots = Map.update!(op.robots, type, &Kernel.+(&1, 1))
    op = %{op | resources: resources, robots: robots}

    work(max, op, time - time_needed)
  end
end
