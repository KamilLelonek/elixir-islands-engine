defmodule IslandsEngine.Board.Agent do
  alias IslandsEngine.{Board, Coordinate}

  def start_link,
    do: Agent.start_link(&Board.new/0)

  def get_coordinate(agent, key)
  when is_atom(key),
    do: Agent.get(agent, &(&1.coordinates[key]))

  def get_coordinates(agent, coordinates),
    do: Enum.map(coordinates, &extract_coordinate(agent, &1))

  defp extract_coordinate(agent, coordinate)
  when is_atom(coordinate),
    do: get_coordinate(agent, coordinate)

  defp extract_coordinate(_agent, coordinate)
  when is_pid(coordinate),
    do: coordinate

  def guess_coordinate(agent, key) do
    agent
    |> get_coordinate(key)
    |> Coordinate.Agent.guess()
  end

  def coordinate_hit?(agent, key) do
    agent
    |> get_coordinate(key)
    |> Coordinate.Agent.hit?()
  end

  def set_coordinate_in_island(agent, key, island) do
    agent
    |> get_coordinate(key)
    |> Coordinate.Agent.set_in_island(island)
  end

  def coordinate_island(agent, key) do
    agent
    |> get_coordinate(key)
    |> Coordinate.Agent.island()
  end

  def to_string(agent),
    do: "%{\n" <> string_body(agent) <> "}"

  defp string_body(agent),
    do: Enum.reduce(Board.keys(), "", &string_coordinate(&1, &2, agent))

  defp string_coordinate(key, string, agent),
    do: string <> "  :" <> format_entry(agent, key) <> ",\n"

  defp format_entry(agent, key),
    do: format_key(key) <> " => " <> format_coordinate(agent, key)

  defp format_coordinate(agent, key),
    do: agent |> get_coordinate(key) |> Coordinate.Agent.to_string()

  defp format_key(key),
    do: key |> Kernel.to_string() |> String.pad_trailing(3)
end
