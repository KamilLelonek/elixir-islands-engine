defmodule IslandsEngine.Game.Server do
  use GenServer

  alias IslandsEngine.{Game, Player, Rules}

  def start_link(name)
  when is_binary(name) and byte_size(name) > 0,
    do: GenServer.start_link(__MODULE__, name, name: {:global, "game:#{name}"})

  def init(name) do
    {:ok, player1} = Player.Agent.start_link(name)
    {:ok, player2} = Player.Agent.start_link()
    {:ok, rules}   = Rules.Agent.start_link()

    {:ok, %Game{player1: player1, player2: player2, rules: rules}}
  end

  def stop(pid),
    do: GenServer.cast(pid, :stop)

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

  def set_islands(server, player),
    do: GenServer.call(server, {:set_islands, player})

  def handle_call(:state, _caller, game),
    do: {:reply, game, game}

  def handle_call({:add_player, name}, _caller, %{rules: rules} = game) do
    rules
    |> Rules.Agent.add_player()
    |> maybe_add_player(game, name)
  end

  def handle_call({:set_island_coordinates, player, island, coordinates}, _caller, %{rules: rules} = game) do
    rules
    |> Rules.Agent.move_island(player)
    |> maybe_set_island_coordinates(player, island, coordinates, game)
  end

  def handle_call({:guess, player, coordinate}, _caller, %{rules: rules} = game) do
    opponent = opponent(game, player)

    rules
    |> Rules.Agent.guess_coordinate(player)
    |> guess_reply(opponent, coordinate)
    |> forest_check(opponent, coordinate)
    |> win_check(opponent, game)
  end

  def handle_call({:set_islands, player}, _caller, %{rules: rules} = game),
    do: {:reply, Rules.Agent.set_islands(rules, player), game}

  defp guess_reply(:ok, opponent_board, coordinate),
    do: Player.Agent.guess_coordinate(opponent_board, coordinate)
  defp guess_reply(:error, _opponent_board, _coordinate),
    do: :error

  defp forest_check(:miss, _opponent, _coordinate),
    do: {:miss, :none}
  defp forest_check(:hit, opponent, coordinate),
    do: {:hit, Player.Agent.forested_island(opponent, coordinate)}
  defp forest_check(:error, _opponent, _coordinate),
    do: :error

  defp win_check({hit_or_miss, :none}, _opponent, game),
    do: {:reply, {hit_or_miss, :none, :no_win}, game}
  defp win_check({:hit, island_key}, opponent, game),
    do: win_status(island_key, Player.Agent.win?(opponent), game)
  defp win_check(:error, _opponent, game),
    do: {:reply, :error, game}

  defp win_status(island_key, true, %{rules: rules} = game) do
    Rules.Agent.win(rules)
    {:reply, {:hit, island_key, :win}, game}
  end
  defp win_status(island_key, false, game),
    do: {:reply, {:hit, island_key, :no_win}, game}

  defp opponent(game, :player1),
    do: game.player2
  defp opponent(game, :player2),
    do: game.player1

  defp maybe_add_player(:ok, %{player2: player2} = game, name) do
    Player.Agent.set_name(player2, name)

    {:reply, :ok, game}
  end
  defp maybe_add_player(reply, game, _name),
    do: {:reply, reply, game}

  defp maybe_set_island_coordinates(:ok, player, island, coordinates, game) do
    game
    |> Map.get(player)
    |> Player.Agent.set_island_coordinates(island, coordinates)

    {:reply, :ok, game}
  end
  defp maybe_set_island_coordinates(reply, _player, _island, _coordinates, game),
    do: {:reply, reply, game}

  def handle_cast(:stop, game),
    do: {:stop, :normal, game}
end
