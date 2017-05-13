defmodule IslandsEngine.IslandSetTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{IslandSet, Island, Coordinate}

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

  describe "forested?" do
    test "should be forested by default" do
      {:ok, island_set} = IslandSet.Agent.start_link()

      assert IslandSet.Agent.forested?(island_set, :atoll)
    end

    test "should check for forested Island" do
      {:ok, island_set} = IslandSet.Agent.start_link()
      {:ok, cooridnate} = Coordinate.Agent.start_link()

      Coordinate.Agent.set_in_island(cooridnate, :dot)
      IslandSet.Agent.set_island_coordinates(island_set, :dot, [cooridnate])

      refute IslandSet.Agent.forested?(island_set, :dot)

      Coordinate.Agent.guess(cooridnate)

      assert IslandSet.Agent.forested?(island_set, :dot)
    end
  end
end
