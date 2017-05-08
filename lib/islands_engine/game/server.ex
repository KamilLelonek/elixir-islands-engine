defmodule IslandsEngine.Game.Server do
  use GenServer

  alias IslandsEngine.{Game, Player}

  def start_link(name),
    do: GenServer.start_link(__MODULE__, name)

  def init(name) do
    {:ok, player1} = Player.Agent.start_link(name)
    {:ok, player2} = Player.Agent.start_link()

    {:ok, %Game{player1: player1, player2: player2}}
  end

  def state(server),
    do: GenServer.call(server, :state)

  def add_player(server, name)
  when not is_nil(name),
    do: GenServer.call(server, {:add_player, name})

  def set_island_coordinates(server, player, island, coordinates)
  when is_atom(island) and is_atom(player),
    do: GenServer.call(server, {:set_island_coordinates, player, island, coordinates})

  def guess_coordinate(server, player, coordinate)
  when is_atom(player) and is_atom(coordinate),
    do: GenServer.call(server, {:guess, player, coordinate})

  def handle_call(:state, _caller, game),
    do: {:reply, game, game}

  def handle_call({:add_player, name}, _caller, game) do
    Player.Agent.set_name(game.player2, name)

    {:reply, :ok, game}
  end

  def handle_call({:set_island_coordinates, player, island, coordinates}, _caller, game) do
    game
    |> Map.get(player)
    |> Player.Agent.set_island_coordinates(island, coordinates)

    {:reply, :ok, game}
  end

  def handle_call({:guess, player, coordinate}, _caller, game) do
    response =
      game
      |> opponent(player)
      |> Player.Agent.guess_coordinate(coordinate)

    {:reply, response, game}
  end

  defp opponent(game, :player1),
    do: game.player2
  defp opponent(game, :player2),
    do: game.player1
end
