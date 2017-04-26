defmodule IslandsEngine.Coordinate.Agent do
  alias IslandsEngine.Coordinate

  def start_link,
    do: Agent.start_link(fn -> %Coordinate{} end)

  def guessed?(agent),
    do: Agent.get(agent, &(&1.guessed?))

  def island(agent),
    do: Agent.get(agent, &(&1.in_island))

  def in_island?(agent) do
    case island(agent) do
      :none -> false
          _ -> true
    end
  end

  def guess(agent),
    do: Agent.update(agent, &Map.put(&1, :guessed?, true))

  def set_in_island(agent, island)
  when is_atom(island),
    do: Agent.update(agent, &Map.put(&1, :in_island, island))

  def hit?(agent),
    do: in_island?(agent) && guessed?(agent)

  def to_string(agent),
    do: "(in_island: #{island(agent)}, guessed: #{guessed?(agent)})"
end
