defmodule Heap do
  defstruct data: nil, size: 0, comparator: nil

  def new, do: %__MODULE__{comparator: :<}
  def new(:>), do: %__MODULE__{comparator: &(&1 > &2)}
  def new(:<), do: %__MODULE__{comparator: &(&1 < &2)}
  def new(func) when is_function(func, 2), do: %__MODULE__{comparator: func}

  def min(), do: new(:<)
  def max(), do: new(:>)

  def empty?(%__MODULE__{data: nil, size: 0}), do: true
  def empty?(%__MODULE__{}), do: false

  def root(%__MODULE__{data: nil, size: 0}), do: nil
  def root(%__MODULE__{data: {v, _}}), do: v

  def size(%__MODULE__{size: size}), do: size

  def push(%__MODULE__{data: data, size: size} = h, value) do
    %{h | data: meld(data, {value, []}, h.comparator), size: size + 1}
  end

  def pop(%__MODULE__{data: nil, size: 0}), do: nil

  def pop(%__MODULE__{data: {_, q}, size: size} = h) do
    %{h | data: pair(q, h.comparator), size: size - 1}
  end

  def member?(%__MODULE__{} = heap, value) do
    has_member?(pop(heap), root(heap), value)
  end

  def split(%__MODULE__{} = heap), do: {root(heap), pop(heap)}

  defp meld(nil, queue, _), do: queue
  defp meld(queue, nil, _), do: queue

  defp meld({k0, l0} = left, {k1, r0} = right, func) do
    case func.(k0, k1) do
      true -> {k0, [right | l0]}
      false -> {k1, [left | r0]}
    end
  end

  defp pair([], _), do: nil
  defp pair([q], _), do: q
  defp pair([q0, q1 | q], d), do: meld(q0, q1, d) |> meld(pair(q, d), d)

  defp has_member?(_, previous, compare) when previous == compare, do: true
  defp has_member?(nil, _, _), do: false

  defp has_member?(heap, _, compare) do
    {previous, heap} = split(heap)
    has_member?(heap, previous, compare)
  end
end

defimpl Enumerable, for: Heap do
  def count(heap), do: {:ok, Heap.size(heap)}
  def member?(heap, value), do: {:ok, Heap.member?(heap, value)}

  def reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}

  def reduce(heap, {:cont, acc}, fun) do
    case Heap.root(heap) do
      nil -> {:done, acc}
      root -> Heap.pop(heap) |> reduce(fun.(root, acc), fun)
    end
  end

  def slice(_heap), do: {:error, __MODULE__}
end

defimpl Collectable, for: Heap do
  def into(heap) do
    {heap,
     fn
       h, {:cont, v} -> Heap.push(h, v)
       h, :done -> h
       _, :halt -> :ok
     end}
  end
end
