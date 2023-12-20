defmodule Y2023.D15 do
  @behaviour AdventOfCode

  @moduledoc """
  https://adventofcode.com/2023/day/15
  https://adventofcode.com/2023/day/15/input
  """

  def input, do: Path.join(["input", "2023", "15.txt"]) |> File.read!()

  alias OrderedMap

  def sample do
    """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      1320

      iex> input() |> part_1()
      514281
  """
  def part_1(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Stream.map(&hash/1)
    |> Enum.sum()
  end

  def hash(str, value \\ 0)
  def hash("", value), do: value
  def hash(<<c::size(8)>> <> rest, value), do: hash(rest, rem((value + c) * 17, 256))

  @doc ~S"""
      iex> sample() |> part_2()
      145

      #iex> input() |> part_2()
      #input()
  """

  defmodule OrderedMap do
    defstruct tuples: []

    def new(), do: %__MODULE__{}

    def put(%__MODULE__{tuples: []} = om, key, value), do: %{om | tuples: [{key, value}]}

    def put(%__MODULE__{tuples: tuples} = om, key, value) do
      %{om | tuples: List.keystore(tuples, key, 0, {key, value})}
    end

    def delete(%__MODULE__{tuples: tuples} = om, key) do
      %{om | tuples: Enum.reject(tuples, &(elem(&1, 0) == key))}
    end

    def get(%__MODULE__{tuples: tuples}, key), do: _get(tuples, key)
    defp _get([], _), do: nil
    defp _get([{key, value} | _], key), do: value
    defp _get([_ | tuples], key), do: _get(tuples, key)

    def values(%__MODULE__{tuples: tuples}), do: Enum.map(tuples, &elem(&1, 1))
  end

  def part_2(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Stream.map(fn piece ->
      case Regex.named_captures(~r/^(?<label>.*)(?<op>-|=(?<focal>\d+))$/, piece) do
        %{"op" => "-", "label" => label} -> {:del, label}
        %{"label" => label, "focal" => focal} -> {:ins, label, String.to_integer(focal)}
      end
    end)
    |> Enum.reduce(%{}, fn
      {:del, label}, boxes ->
        Map.update(boxes, hash(label), OrderedMap.new(), &OrderedMap.delete(&1, label))

      {:ins, label, val}, boxes ->
        box = hash(label)

        boxes
        |> Map.put_new(box, OrderedMap.new())
        |> Map.update!(box, &OrderedMap.put(&1, label, val))
    end)
    |> Stream.flat_map(fn {box, map} ->
      map
      |> OrderedMap.values()
      |> Stream.with_index()
      |> Stream.map(fn {value, index} -> (box + 1) * (index + 1) * value end)
    end)
    |> Enum.sum()
  end
end
