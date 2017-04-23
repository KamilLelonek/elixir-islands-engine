defmodule IslandsEngine.Coordinate.Agent do
  alias IslandsEngine.Coordinate

  def start_link,
    do: Agent.start_link(fn -> %Coordinate{} end)

  def guessed?(agent),
    do: Agent.get(agent, fn coordinate -> coordinate.guessed? end)

  def island(agent),
    do: Agent.get(agent, fn coordinate -> coordinate.in_island end)

  def in_island?(agent) do
    case island(agent) do
      :none -> false
          _ -> true
    end
  end

  def guess(agent),
    do: Agent.update(agent, fn coordinate -> Map.put(coordinate, :guessed?, true) end)

  def set_in_island(agent, island)
  when is_atom(island),
    do: Agent.update(agent, fn coordinate -> Map.put(coordinate, :in_island, island) end)

  def hit?(agent),
    do: in_island?(agent) && guessed?(agent)

  def to_string(agent),
    do: "(in_island: #{island(agent)}, guessed: #{guessed?(agent)})"
end
