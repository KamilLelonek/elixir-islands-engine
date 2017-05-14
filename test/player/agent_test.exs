defmodule IslandsEngine.Player.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Player, Board, IslandSet, Island, Coordinate}

  setup do
    {:ok, pid} = Player.Agent.start_link()

    {:ok, agent: pid}
  end

  test "should change a Player name", %{agent: agent} do
    assert :none = Player.Agent.get_name(agent)

    Player.Agent.set_name(agent, "Kamil")

    assert "Kamil" = Player.Agent.get_name(agent)
  end

  test "should allow to set Island Coordinates", %{agent: agent} do
    Player.Agent.set_island_coordinates(agent, :dot, [:c3])

    island_set = Player.Agent.get_island_set(agent)
    island     = IslandSet.Agent.get_island(island_set, :dot)

    assert [coordinates] = Island.Agent.coordinates(island)

    board = Player.Agent.get_board(agent)

    assert ^coordinates = Board.Agent.get_coordinate(board, :c3)
  end

  test "should guess a Coordinate", %{agent: agent} do
    assert :miss = Player.Agent.guess_coordinate(agent, :a1)

    assert agent
    |> Player.Agent.get_board()
    |> Board.Agent.get_coordinate(:a1)
    |> Coordinate.Agent.guessed?()
  end

  test "should check forested Island", %{agent: agent} do
    coordinate_key = :c3
    island_key     = :dot

    Player.Agent.set_island_coordinates(agent, island_key, [coordinate_key])

    assert :none = Player.Agent.forested_island(agent, coordinate_key)
    assert :hit  = Player.Agent.guess_coordinate(agent, coordinate_key)

    assert ^island_key = Player.Agent.forested_island(agent, coordinate_key)
  end
end
