defmodule IslandsEngine.Game.ServerTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Game.Server, Player, IslandSet, Island, Board}

  setup do
    {:ok, pid} = Server.start_link(:name)

    {:ok, server: pid}
  end

  test "should initalize a Game", %{server: server} do
    %{player1: player1, player2: player2} = Server.state(server)

    assert :name = Player.Agent.get_name(player1)
    assert :none = Player.Agent.get_name(player2)
  end

  test "should add a new Player", %{server: server} do
    Server.add_player(server, :kamil)

    %{player1: player1, player2: player2} = Server.state(server)

    assert :name  = Player.Agent.get_name(player1)
    assert :kamil = Player.Agent.get_name(player2)
  end

  test "should set Island Coordinates", %{server: server} do
    Server.set_island_coordinates(server, :player1, :dot, [:a1])

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
end
