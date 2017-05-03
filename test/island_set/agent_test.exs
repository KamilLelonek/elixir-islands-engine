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
    {:ok, coordinates} = Coordinate.Agent.start_link()

    refute Coordinate.Agent.in_island?(coordinates)

    IslandSet.Agent.set_island_coordinates(agent, :dot, [coordinates])

    assert Coordinate.Agent.in_island?(coordinates)
    assert :dot = Coordinate.Agent.island(coordinates)

    island = IslandSet.Agent.get_island(agent, :dot)

    assert [^coordinates] = Island.Agent.coordinates(island)
  end
end
