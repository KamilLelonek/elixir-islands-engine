defmodule IslandsEngine.Player.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Player, IslandSet, Island}

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

    assert [_coordinates] = Island.Agent.coordinates(island)
  end
end
