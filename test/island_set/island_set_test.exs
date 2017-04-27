defmodule IslandsEngine.IslandSetTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{IslandSet, Island}

  test "should return IslandSet keys" do
    assert ~w(atoll dot l_shape s_shape square)a = IslandSet.keys()
  end

  test "should generate a new IslandSet" do
    %IslandSet{
      atoll:   pid1,
      dot:     pid2,
      l_shape: pid3,
      s_shape: pid4,
      square:  pid5
    } = IslandSet.new()

    assert [] = Island.Agent.coordinates(pid1)
    assert [] = Island.Agent.coordinates(pid2)
    assert [] = Island.Agent.coordinates(pid3)
    assert [] = Island.Agent.coordinates(pid4)
    assert [] = Island.Agent.coordinates(pid5)
  end
end
