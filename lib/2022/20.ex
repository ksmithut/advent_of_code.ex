import AdventOfCode

solution 2022, 20 do
  @moduledoc """
  https://adventofcode.com/2022/day/20
  https://adventofcode.com/2022/day/20/input
  """

  def sample do
    """
    1
    2
    -3
    3
    -2
    0
    4
    """
  end

  @doc ~S"""
      iex> sample() |> part_1()
      3

      iex> input() |> part_1()
      10763
  """
  def part_1(input) do
    decrypt(input)
  end

  defp decrypt(input, key \\ 1, mix \\ 1) do
    initial_values =
      input
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    length = length(initial_values)

    initial_values
    |> Enum.map(fn value ->
      modified_value = value * key
      short_modified_value = Integer.mod(modified_value, length - 1)
      {short_modified_value, modified_value}
    end)
    |> DoublyLinkedList.new()
    |> mix_times(mix)
    |> grove_coordinates(fn {{value, _}, _} -> value == 0 end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp grove_coordinates(list, predicate) do
    {_, ref} = DoublyLinkedList.find(list, predicate)
    {first, ref} = DoublyLinkedList.relative(list, ref, 1000)
    {second, ref} = DoublyLinkedList.relative(list, ref, 1000)
    {third, _ref} = DoublyLinkedList.relative(list, ref, 1000)
    [first, second, third]
  end

  # defp inspect_list(list) do
  #   list |> DoublyLinkedList.to_list() |> IO.inspect()
  #   list
  # end

  @doc ~S"""
      iex> sample() |> part_2()
      1623178306

      iex> input() |> part_2()
      4979911042808
  """
  def part_2(input) do
    decrypt(input, 811_589_153, 10)
  end

  defp mix_times(list, times) do
    mix_times(list, list, times)
  end

  defp mix_times(list, _initial_list, 0), do: list

  defp mix_times(list, initial_list, times) do
    list
    |> mix(initial_list)
    |> mix_times(initial_list, times - 1)
  end

  defp mix(list, initial_list) do
    DoublyLinkedList.reduce(initial_list, list, fn
      {{0, _}, _ref}, list ->
        list

      {{value, _}, ref}, list when value > 0 ->
        next = DoublyLinkedList.next(list, ref)
        {list, node_value, ref} = DoublyLinkedList.remove(list, ref)
        {_, next_ref} = DoublyLinkedList.relative(list, next, value)
        DoublyLinkedList.insert_before(list, next_ref, node_value, ref)

      {{value, _}, ref}, list when value < 0 ->
        prev = DoublyLinkedList.prev(list, ref)
        {list, node_value, ref} = DoublyLinkedList.remove(list, ref)
        {_, prev_ref} = DoublyLinkedList.relative(list, prev, value)
        DoublyLinkedList.insert_after(list, prev_ref, node_value, ref)
    end)
  end
end

defmodule DoublyLinkedList do
  defstruct [:head, :ref_map]

  def new([_ | _] = list) do
    data = list |> Enum.with_index() |> Enum.zip(Stream.repeatedly(&make_ref/0))
    data_length = length(data)
    index_map = Enum.into(data, %{}, fn {{_value, index}, ref} -> {index, ref} end)

    ref_map =
      Enum.into(data, %{}, fn {{value, index}, ref} ->
        left_index = rem(index - 1 + data_length, data_length)
        right_index = rem(index + 1, data_length)
        {ref, {value, Map.get(index_map, left_index), Map.get(index_map, right_index)}}
      end)

    head = data |> List.first() |> elem(1)

    %__MODULE__{head: head, ref_map: ref_map}
  end

  def reduce(%__MODULE__{ref_map: ref_map, head: head}, acc, reducer) do
    Enum.reduce_while(Stream.cycle([nil]), {acc, head, head}, fn _, {acc, head, curr} ->
      {value, _, next} = Map.fetch!(ref_map, curr)
      acc = reducer.({value, curr}, acc)
      if next == head, do: {:halt, acc}, else: {:cont, {acc, head, next}}
    end)
  end

  def reduce_while(%__MODULE__{ref_map: ref_map, head: head}, acc, reducer) do
    Enum.reduce_while(Stream.cycle([nil]), {acc, head, head}, fn _, {acc, head, curr} ->
      {value, _, next} = Map.fetch!(ref_map, curr)

      case reducer.({value, curr}, acc) do
        {:halt, acc} -> {:cont, {acc, head, next}}
        {:cont, acc} -> if next == head, do: {:halt, acc}, else: {:cont, {acc, head, next}}
      end
    end)
  end

  def map(%__MODULE__{} = list, mapper) do
    list
    |> reduce([], fn item, acc -> [mapper.(item) | acc] end)
    |> Enum.reverse()
  end

  def find(%__MODULE__{} = list, predicate) do
    reduce_while(list, nil, fn {value, ref} = item, acc ->
      if predicate.(item), do: {:halt, {value, ref}}, else: {:cont, acc}
    end)
  end

  def to_list(%__MODULE__{} = list), do: map(list, &elem(&1, 0))

  def remove(%__MODULE__{ref_map: ref_map, head: head} = list, ref) do
    {value, prev, next} = Map.get(ref_map, ref)

    ref_map =
      ref_map
      |> Map.update!(prev, fn {value, prev, _next} -> {value, prev, next} end)
      |> Map.update!(next, fn {value, _prev, next} -> {value, prev, next} end)
      |> Map.delete(ref)

    head = if head == ref, do: next, else: head

    {%{list | ref_map: ref_map, head: head}, value, ref}
  end

  def value(%__MODULE__{ref_map: ref_map}, ref) do
    {value, _, _} = Map.get(ref_map, ref)
    value
  end

  def next(%__MODULE__{ref_map: ref_map}, ref) do
    {_, _, next} = Map.get(ref_map, ref)
    next
  end

  def prev(%__MODULE__{ref_map: ref_map}, ref) do
    {_, prev, _} = Map.get(ref_map, ref)
    prev
  end

  def insert_after(%__MODULE__{ref_map: ref_map} = list, ref, value, new_ref) do
    next = next(list, ref)

    ref_map =
      ref_map
      |> Map.put(new_ref, {value, ref, next})
      |> Map.update!(ref, fn {value, prev, _next} -> {value, prev, new_ref} end)
      |> Map.update!(next, fn {value, _prev, next} -> {value, new_ref, next} end)

    %{list | ref_map: ref_map}
  end

  def insert_before(%__MODULE__{ref_map: ref_map} = list, ref, value, new_ref) do
    prev = prev(list, ref)

    ref_map =
      ref_map
      |> Map.put(new_ref, {value, prev, ref})
      |> Map.update!(ref, fn {value, _prev, next} -> {value, new_ref, next} end)
      |> Map.update!(prev, fn {value, prev, _next} -> {value, prev, new_ref} end)

    %{list | ref_map: ref_map}
  end

  def relative(%__MODULE__{ref_map: ref_map}, ref, 0) do
    case Map.get(ref_map, ref) do
      nil -> nil
      {value, _, _} -> {value, ref}
    end
  end

  def relative(%__MODULE__{ref_map: ref_map} = list, ref, left) when left < 0 do
    prev_ref = ref_map |> Map.get(ref) |> elem(1)
    relative(list, prev_ref, left + 1)
  end

  def relative(%__MODULE__{ref_map: ref_map} = list, ref, left) when left > 0 do
    next_ref = ref_map |> Map.get(ref) |> elem(2)
    relative(list, next_ref, left - 1)
  end
end
