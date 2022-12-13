defmodule Permutations do
  # Works if every item in the list is unique
  def of([]), do: [[]]
  def of(list), do: for(h <- list, t <- of(list -- [h]), do: [h | t])
end
