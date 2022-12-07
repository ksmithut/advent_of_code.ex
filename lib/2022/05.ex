import AdventOfCode

solution 2022, 5 do
  @moduledoc """
  https://adventofcode.com/2022/day/5
  https://adventofcode.com/2022/day/5/input
  """

  def sample do
    """
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      "CMZ"

      iex> input() |> part_1()
      "TDCHVHJTG"
  """
  def part_1(input) do
    input
    |> parse_input()
    |> run(&Enum.reverse/1)
  end

  defp parse_input(input) do
    [state, instructions] = String.split(input, "\n\n")
    {parse_state(state), parse_instructions(instructions)}
  end

  defp parse_state(state_input) do
    lines = state_input |> String.split("\n", trim: true)
    max_length = lines |> Enum.map(&String.length/1) |> Enum.max()

    lines
    |> Enum.map(fn line ->
      line
      |> String.pad_trailing(max_length)
      |> String.graphemes()
      |> Enum.chunk_every(4)
      |> Enum.map(&Enum.at(&1, 1))
    end)
    |> Enum.zip_with(fn stack ->
      {stack, [num]} = Enum.split(stack, length(stack) - 1)
      {String.to_integer(num), Enum.reject(stack, &(&1 == " "))}
    end)
    |> Map.new()
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ["move", amount, "from", from, "to", to] = String.split(line)

      [amount, from, to]
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp print_top(state) do
    state
    |> Enum.map(fn {num, [val | _]} -> {num, val} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join(&elem(&1, 1))
  end

  defp run({state, instructions}, on_update) do
    instructions
    |> Enum.reduce(state, fn {amount, from, to}, state ->
      {to_move, rest} = Enum.split(state[from], amount)

      state
      |> Map.put(from, rest)
      |> Map.update!(to, &Enum.concat(on_update.(to_move), &1))
    end)
    |> print_top()
  end

  @doc ~S"""
      iex> sample() |> part_2()
      "MCD"

      iex> input() |> part_2()
      "NGCMPJLHV"
  """
  def part_2(input) do
    input
    |> parse_input()
    |> run(& &1)
  end
end
