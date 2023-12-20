defmodule Y2022.D07 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2022/day/7
  https://adventofcode.com/2022/day/7/input
  """

  def input, do: Path.join(["input", "2022", "07.txt"]) |> File.read!()

  def sample do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      95437

      iex> input() |> part_1()
      1886043
  """
  def part_1(input) do
    input
    |> build_tree()
    |> dir_sizes()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  defp build_tree(input), do: input |> String.split("\n", trim: true) |> build_tree(%{}, [])
  defp build_tree([], tree, _stack), do: tree
  defp build_tree(["$ cd /" | rest], tree, _stack), do: build_tree(rest, tree, [])
  defp build_tree(["$ cd .." | rest], tree, stack), do: build_tree(rest, tree, tl(stack))
  defp build_tree(["$ ls" | rest], tree, stack), do: build_tree(rest, tree, stack)
  defp build_tree(["dir " <> _dir | rest], tree, stack), do: build_tree(rest, tree, stack)

  defp build_tree(["$ cd " <> dir | rest], tree, stack) do
    stack = [dir | stack]
    tree = put_in(tree, Enum.reverse(stack), %{})
    build_tree(rest, tree, stack)
  end

  defp build_tree([file | rest], tree, stack) do
    [size, name] = String.split(file)
    tree = put_in(tree, Enum.reverse([name | stack]), String.to_integer(size))
    build_tree(rest, tree, stack)
  end

  defp dir_sizes(map) do
    this_size = dir_size(map)
    sub_dir_sizes = map |> Map.values() |> Enum.filter(&is_map/1) |> Enum.flat_map(&dir_sizes/1)
    [this_size | sub_dir_sizes]
  end

  defp dir_size(map) when is_integer(map), do: map
  defp dir_size(map), do: map |> Map.values() |> Enum.reduce(0, &(dir_size(&1) + &2))

  @disk_size 70_000_000
  @update_requirement 30_000_000

  @doc ~S"""
      iex> sample() |> part_2()
      24933642

      iex> input() |> part_2()
      3842121
  """
  def part_2(input) do
    tree = build_tree(input)
    used = dir_size(tree)
    unused = @disk_size - used
    min_to_delete = @update_requirement - unused

    tree
    |> dir_sizes()
    |> Enum.filter(&(&1 >= min_to_delete))
    |> Enum.min()
  end
end
