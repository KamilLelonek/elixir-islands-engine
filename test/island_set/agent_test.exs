defmodule IslandsEngine.IslandSet.AgentTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{IslandSet, Island}

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
end
