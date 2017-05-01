defmodule IslandsEngine.Player.Agent do
  alias IslandsEngine.{Player, Board, IslandSet}

  def start_link(name \\ :none),
    do: Agent.start_link(fn -> Player.new(name) end)

  def set_name(agent, name),
    do: Agent.update(agent, &Map.put(&1, :name, name))

  def get_name(agent),
    do: Agent.get(agent, &(&1.name))

  def to_string(agent),
    do: "%Player{\n" <> string_body(agent) <> "}"

  defp string_body(agent),
    do: agent |> Agent.get(&(&1)) |> agent_string()

  defp agent_string(state),
    do: player_string(state) <> island_set_string(state) <> board_string(state)

  defp player_string(%{name: name}),
    do: "  :name       => " <> "#{name}" <> ",\n"

  defp island_set_string(%{island_set: island_set}),
    do: "  :island_set => " <> IslandSet.Agent.to_string(island_set) <> ",\n"

  defp board_string(%{board: board}),
    do: "  :board      => " <> Board.Agent.to_string(board) <> ",\n"
end
