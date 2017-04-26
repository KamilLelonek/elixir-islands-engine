defmodule IslandsEngine.BoardTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Board

  test "should generate a new Board" do
    assert %{coordinates: coordinates} = Board.new()

    fields = Map.keys(coordinates)

    assert 100 = Enum.count(fields)
    assert Enum.member?(fields, :a1)
  end
end
