defmodule IslandsEngine.Game.ServerTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Game.Server, Player, IslandSet, Island, Board, Coordinate, Rules}

  @name "Frank"

  setup do
    {:ok, pid} = Server.start_link(@name)

    {:ok, server: pid}
  end

  test "should initalize a Game", %{server: server} do
    %{player1: player1, player2: player2, rules: rules} = Server.state(server)

    assert @name == Player.Agent.get_name(player1)
    assert :none        = Player.Agent.get_name(player2)
    assert :initialized = Rules.Agent.show_current_state(rules)
  end

  test "should add a new Player", %{server: server} do
    assert :ok    = Server.add_player(server, :kamil)
    assert :error = Server.add_player(server, :kamil)

    %{player1: player1, player2: player2} = Server.state(server)

    assert @name == Player.Agent.get_name(player1)
    assert :kamil = Player.Agent.get_name(player2)
  end

  test "should set Island Coordinates", %{server: server} do
    :ok = Server.add_player(server, :player2)
    :ok = Server.set_island_coordinates(server, :player1, :dot, [:a1])

    %{player1: player1} = Server.state(server)

    assert player1
    |> Player.Agent.get_island_set()
    |> IslandSet.Agent.get_island(:dot)
    |> Island.Agent.coordinates()
    |> List.first()
    ==
    player1
    |> Player.Agent.get_board()
    |> Board.Agent.get_coordinate(:a1)
  end

  test "should hit an Island", %{server: server} do
    :ok = Server.add_player(server, :player2)
    :ok = Server.set_island_coordinates(server, :player1, :dot, [:a1])
    :ok = Server.set_island_coordinates(server, :player2, :dot, [:a1])
    :ok = Server.set_islands(server, :player1)
    :ok = Server.set_islands(server, :player2)

    assert {:hit, :dot, :win} = Server.guess_coordinate(server, :player1, :a1)

    assert server
    |> Server.state()
    |> Map.fetch!(:player2)
    |> Player.Agent.get_board()
    |> Board.Agent.get_coordinate(:a1)
    |> Coordinate.Agent.guessed?()
  end

  test "should guess a Coordinate", %{server: server} do
    :ok = Server.add_player(server, :player2)
    :ok = Server.set_island_coordinates(server, :player1, :dot,   [:a1])
    :ok = Server.set_island_coordinates(server, :player2, :dot,   [:a1])
    :ok = Server.set_island_coordinates(server, :player2, :atoll, [:c7])
    :ok = Server.set_islands(server, :player1)
    :ok = Server.set_islands(server, :player2)

    assert {:hit, :atoll, :no_win} = Server.guess_coordinate(server, :player1, :c7)
  end

  test "should start and stop a Game", %{server: server} do
    assert {:error, {:already_started, ^server}} = Server.start_link(@name)
    assert %{}                                   = Server.state({:global, "game:#{@name}"})
    assert :ok                                   = Server.stop({:global, "game:#{@name}"})
  end

  test "should set an Island", %{server: server} do
    Server.add_player(server, :kamil)

    assert :ok = Server.set_islands(server, :player1)
    assert :ok = Server.set_islands(server, :player2)
  end
end
