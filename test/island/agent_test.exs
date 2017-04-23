defmodule IslandsEngine.Island.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Coordinate, Island.Agent}

  setup do
    {:ok, pid} = Agent.start_link()

    {:ok, agent: pid}
  end

  test "should allow Island to replace Coordinates", %{agent: agent} do
    assert [] = Agent.coordinates(agent)

    Agent.replace_coordinates(agent, [%Coordinate{}])

    assert [%Coordinate{guessed?: false, in_island: :none}] = Agent.coordinates(agent)
  end

  test "should check if Island is forested", %{agent: agent} do
    {:ok, coordinate_agent} = Coordinate.Agent.start_link()

    Agent.replace_coordinates(agent, [coordinate_agent])

    refute Agent.forested?(agent)

    Coordinate.Agent.set_in_island(coordinate_agent, :teneryfa)
    Coordinate.Agent.guess(coordinate_agent)

    assert Agent.forested?(agent)
  end
end
