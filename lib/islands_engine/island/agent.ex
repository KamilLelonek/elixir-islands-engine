defmodule IslandsEngine.Island.Agent do
  alias IslandsEngine.{Island, Coordinate}

  def start_link,
    do: Agent.start_link(fn -> %Island{} end)

  def coordinates(agent),
    do: Agent.get(agent, &(&1.coordinates))

  def replace_coordinates(agent, coordinates)
  when is_list(coordinates),
    do: Agent.update(agent, &Map.put(&1, :coordinates, coordinates))

  def forested?(agent) do
    agent
    |> coordinates()
    |> Enum.all?(&Coordinate.Agent.hit?/1)
  end

  def to_string(agent),
    do: "[" <> coordinate_strings(agent) <> "]"

  def coordinate_strings(agent) do
    agent
    |> coordinates()
    |> Enum.map(&Coordinate.Agent.to_string/1)
    |> Enum.join(", ")
  end
end
