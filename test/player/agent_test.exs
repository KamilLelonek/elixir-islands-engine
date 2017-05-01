defmodule IslandsEngine.Player.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Player

  setup do
    {:ok, pid} = Player.Agent.start_link()

    {:ok, agent: pid}
  end

  test "should change a Player name", %{agent: agent} do
    assert :none = Player.Agent.get_name(agent)

    Player.Agent.set_name(agent, "Kamil")

    assert "Kamil" = Player.Agent.get_name(agent)
  end
end
