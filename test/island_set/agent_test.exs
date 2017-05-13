defmodule IslandsEngine.IslandSet.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{IslandSet, Island, Coordinate}

  setup do
    {:ok, pid} = IslandSet.Agent.start_link()

    {:ok, agent: pid}
  end

  test "should return an Island from an IslandSet", %{agent: agent} do
    Enum.each(
      IslandSet.keys(),
      &(assert [] = agent |> IslandSet.Agent.get_island(&1) |> Island.Agent.coordinates())
    )
  end

  test "should set Island Coordinates", %{agent: agent} do
    {:ok, coordinate} = Coordinate.Agent.start_link()

    refute Coordinate.Agent.in_island?(coordinate)

    IslandSet.Agent.set_island_coordinates(agent, :dot, [coordinate])

    assert Coordinate.Agent.in_island?(coordinate)
    assert :dot = Coordinate.Agent.island(coordinate)

    island = IslandSet.Agent.get_island(agent, :dot)

    assert [^coordinate] = Island.Agent.coordinates(island)
  end

  test "should check a fortested Island", %{agent: agent} do
    refute IslandSet.Agent.forested?(agent, :none)

    {:ok, coordinate} = Coordinate.Agent.start_link()
    IslandSet.Agent.set_island_coordinates(agent, :dot, [coordinate])

    refute IslandSet.Agent.forested?(agent, :dot)
    refute IslandSet.Agent.all_forested?(agent)

    Coordinate.Agent.guess(coordinate)

    assert IslandSet.Agent.forested?(agent, :dot)
    assert IslandSet.Agent.all_forested?(agent)
  end
end
