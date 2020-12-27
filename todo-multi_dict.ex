defmodule MultiDict do
  def new, do: Map.new()

  def add_entry(dict, key, value) do
    Map.update(
      dict,
      key,
      [value],
      &[value | &1]
    )
  end

  def entries(dict, value) do
    Map.get(dict, value, [])
  end
end
