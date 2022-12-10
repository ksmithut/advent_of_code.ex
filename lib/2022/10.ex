import AdventOfCode

solution 2022, 10 do
  @moduledoc """
  https://adventofcode.com/2022/day/10
  https://adventofcode.com/2022/day/10/input
  """

  def sample do
    """
    addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      13140

      iex> input() |> part_1()
      14820
  """
  def part_1(input) do
    input
    |> run_instructions()
    |> Stream.map(fn {x, cycle} -> x * cycle end)
    |> Enum.slice(19..219//40)
    |> Enum.sum()
  end

  defp run_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> then(&{&1, [], 1})
    |> Stream.iterate(&run/1)
    |> Stream.map(&elem(&1, 2))
    |> Stream.with_index(1)
  end

  defp run({instructions, queue, x}) do
    {next, instructions} = queue_instruction(instructions)
    {add, queue} = run_queue(queue ++ next)
    {instructions, queue, x + add}
  end

  defp queue_instruction([]), do: {[], []}
  defp queue_instruction(["noop" | rest]), do: {[{0, 0}], rest}
  defp queue_instruction(["addx " <> value | rest]), do: {[{1, String.to_integer(value)}], rest}

  defp run_queue([]), do: {0, []}
  defp run_queue([{0, value} | queue]), do: {value, queue}
  defp run_queue([{timer, value} | queue]), do: {0, [{timer - 1, value} | queue]}

  @doc ~S"""
      iex> sample() |> part_2()
      ~s(##..##..##..##..##..##..##..##..##..##..\n###...###...###...###...###...###...###.\n####....####....####....####....####....\n#####.....#####.....#####.....#####.....\n######......######......######......####\n#######.......#######.......#######.....)

      iex> input() |> part_2()
      ~s(###..####.####.#..#.####.####.#..#..##..\n#..#....#.#....#.#..#....#....#..#.#..#.\n#..#...#..###..##...###..###..####.#..#.\n###...#...#....#.#..#....#....#..#.####.\n#.#..#....#....#.#..#....#....#..#.#..#.\n#..#.####.####.#..#.####.#....#..#.#..#.)
  """
  def part_2(input) do
    input
    |> run_instructions()
    |> Stream.map(fn
      {x, cycle} when rem(cycle - 1, 40) in (x - 1)..(x + 1) -> "#"
      _ -> "."
    end)
    |> Stream.chunk_every(40)
    |> Stream.map(&Enum.join(&1))
    |> Stream.take(6)
    |> Enum.join("\n")
  end
end
