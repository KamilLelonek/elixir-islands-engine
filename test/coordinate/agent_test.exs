defmodule IslandsEngine.Coordinate.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Coordinate.Agent

  setup do
    {:ok, pid} = Agent.start_link()

    {:ok, agent: pid}
  end

  test "should allow Coordinate to be guessed", %{agent: agent} do
    refute Agent.guessed?(agent)

    Agent.guess(agent)

    assert Agent.guessed?(agent)
  end

  test "should allow Coordinate to set in island", %{agent: agent} do
    refute Agent.in_island?(agent)
    assert :none = Agent.island(agent)

    Agent.set_in_island(agent, :teneryfa)

    assert :teneryfa = Agent.island(agent)
    assert Agent.in_island?(agent)
  end

  test "should check if Coordinate is hit", %{agent: agent} do
    refute Agent.hit?(agent)

    Agent.set_in_island(agent, :teneryfa)

    refute Agent.hit?(agent)

    Agent.guess(agent)

    assert Agent.hit?(agent)
  end
end
