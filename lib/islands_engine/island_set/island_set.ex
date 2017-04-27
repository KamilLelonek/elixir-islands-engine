defmodule IslandsEngine.IslandSet do
  defstruct atoll:   :none,
            dot:     :none,
            l_shape: :none,
            s_shape: :none,
            square:  :none

  alias IslandsEngine.Island

  def keys do
    __MODULE__
    |> Map.from_struct()
    |> Map.keys()
  end

  def new,
    do: Enum.reduce(keys(), %__MODULE__{}, &put_island/2)

  defp put_island(key, set) do
    {:ok, island} = Island.Agent.start_link()

    Map.put(set, key, island)
  end
end
