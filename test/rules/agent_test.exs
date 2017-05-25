defmodule IslandsEngine.Rules.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Rules.Agent

  setup do
    {:ok, pid} = Agent.start_link()

    {:ok, agent: pid}
  end

  test "should start with :initialized state", %{agent: agent} do
    assert :initialized = Agent.show_current_state(agent)
  end

  test "should set the first Player", %{agent: agent} do
    assert :ok          = Agent.add_player(agent)
    assert :players_set = Agent.show_current_state(agent)
  end

  test "should move Islands", %{agent: agent} do
    Agent.add_player(agent)

    assert :ok = Agent.move_island(agent, :player1)
    assert :ok = Agent.move_island(agent, :player1)
    assert :ok = Agent.move_island(agent, :player2)
    assert :ok = Agent.move_island(agent, :player2)

    assert :players_set = Agent.show_current_state(agent)
  end
end
