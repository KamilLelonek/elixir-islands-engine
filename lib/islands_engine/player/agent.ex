defmodule IslandsEngine.Player.Agent do
  alias IslandsEngine.{Player, Board, IslandSet}

  def start_link(name \\ :none),
    do: Agent.start_link(fn -> Player.new(name) end)

  def set_name(agent, name),
    do: Agent.update(agent, &Map.put(&1, :name, name))

  def get_name(agent),
    do: Agent.get(agent, &(&1.name))

  def get_board(agent),
    do: Agent.get(agent, &(&1.board))

  def get_island_set(agent),
    do: Agent.get(agent, &(&1.island_set))

  def set_island_coordinates(agent, island_key, coordinates)
  when is_list(coordinates) do
    island_set  = get_island_set(agent)
    coordinates = get_board_coordinates(agent, coordinates)

    IslandSet.Agent.set_island_coordinates(island_set, island_key, coordinates)
  end

  defp get_board_coordinates(agent, coordinates) do
    agent
    |> get_board()
    |> Board.Agent.get_coordinates(coordinates)
  end

  def guess_coordinate(agent, coordinate) do
    board = get_board(agent)

    Board.Agent.guess_coordinate(board, coordinate)

    board
    |> Board.Agent.coordinate_hit?(coordinate)
    |> coordinate_hit?()
  end

  defp coordinate_hit?(true),  do: :hit
  defp coordinate_hit?(false), do: :miss

  def forested_island(opponent, coordinate) do
    island_key =
      opponent
      |> get_board()
      |> Board.Agent.coordinate_island(coordinate)

    opponent
    |> get_island_set()
    |> IslandSet.Agent.forested?(island_key)
    |> forested_island_key(island_key)
  end

  defp forested_island_key(true, island_key),
    do: island_key
  defp forested_island_key(false, _island_key),
    do: :none

  def win?(opponent) do
    opponent
    |> get_island_set()
    |> IslandSet.Agent.all_forested?()
  end

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
