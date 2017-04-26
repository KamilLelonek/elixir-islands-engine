defmodule IslandsEngine.Board.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Coordinate, Board.Agent}

  setup do
    {:ok, pid} = Agent.start_link()

    {:ok, agent: pid}
  end

  test "should guess a Coordinate", %{agent: agent} do
    coordinate = Agent.get_coordinate(agent, :a1)

    refute Coordinate.Agent.guessed?(coordinate)

    Agent.guess_coordinate(agent, :a1)

    assert Coordinate.Agent.guessed?(coordinate)
  end

  test "shoud put Coordinate in island", %{agent: agent} do
    Agent.set_coordinate_in_island(agent, :a1, :teneryfa)

    assert :teneryfa = Agent.coordinate_island(agent, :a1)
  end

  test "should check Coordinate hit", %{agent: agent} do
    refute Agent.coordinate_hit?(agent, :a1)

    Agent.set_coordinate_in_island(agent, :a1, :teneryfa)
    Agent.guess_coordinate(agent, :a1)

    assert Agent.coordinate_hit?(agent, :a1)
  end
end
