defmodule IslandsEngine.IslandSet.Agent do
  alias IslandsEngine.{IslandSet, Island, Coordinate}

  def start_link,
    do: Agent.start_link(&IslandSet.new/0)

  def get_island(agent, key),
    do: Agent.get(agent, &Map.fetch!(&1, key))

  def set_island_coordinates(agent, island_key, coordinates)
  when is_list(coordinates) do
    island              = get_island(agent, island_key)
    current_coordinates = Island.Agent.coordinates(island)

    Island.Agent.replace_coordinates(island, coordinates)
    Coordinate.Agent.set_all_in_island(current_coordinates, :none)
    Coordinate.Agent.set_all_in_island(coordinates, island_key)
  end

  def to_string(agent),
    do: "%IslandSet{\n" <> string_body(agent) <> "}"

  defp string_body(agent),
    do: Enum.reduce(IslandSet.keys(), "", &string_island(&1, &2, agent))

  defp string_island(key, string, agent),
    do: string <> "  :" <> format_entry(agent, key) <> ",\n"

  defp format_entry(agent, key),
    do: format_key(key) <> " => " <> format_island(agent, key)

  defp format_island(agent, key),
    do: agent |> get_island(key) |> Island.Agent.to_string()

  defp format_key(key),
    do: key |> Kernel.to_string() |> String.pad_trailing(8)
end
