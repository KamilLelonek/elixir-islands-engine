defmodule IslandsEngine.Player do
  defstruct name:       :none,
            board:      :none,
            island_set: :none

  alias IslandsEngine.{Board, IslandSet}

  def new(name),
    do: %__MODULE__{board: board(), island_set: island_set(), name: name}

  defp board,
    do: state(Board.Agent.start_link())

  defp island_set,
    do: state(IslandSet.Agent.start_link())

  defp state({:ok, state}),
    do: state
end
