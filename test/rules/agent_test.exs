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

  test "should start player1 turn", %{agent: agent} do
    Agent.add_player(agent)
    Agent.move_island(agent, :player1)
    Agent.move_island(agent, :player2)

    assert :ok           = Agent.set_islands(agent, :player1)
    assert :players_set  = Agent.show_current_state(agent)
    assert :ok           = Agent.set_islands(agent, :player2)
    assert :player1_turn = Agent.show_current_state(agent)
  end

  test "should allow to guess a Coordinate only when it's a specific player turn", %{agent: agent} do
    Agent.add_player(agent)
    Agent.set_islands(agent, :player1)
    Agent.set_islands(agent, :player2)

    assert :error        = Agent.guess_coordinate(agent, :player2)
    assert :ok           = Agent.guess_coordinate(agent, :player1)
    assert :player2_turn = Agent.show_current_state(agent)
  end

  test "should make the game over", %{agent: agent} do
    Agent.add_player(agent)
    Agent.set_islands(agent, :player1)
    Agent.set_islands(agent, :player2)
    Agent.win(agent)

    assert :game_over = Agent.show_current_state(agent)
  end
end
