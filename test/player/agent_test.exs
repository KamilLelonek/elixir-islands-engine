defmodule IslandsEngine.Player.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Player, Board, IslandSet, Island}

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
end
