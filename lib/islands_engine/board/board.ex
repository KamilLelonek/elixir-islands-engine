defmodule IslandsEngine.Board do
  defstruct coordinates: %{}

  alias IslandsEngine.Coordinate

  @letters ~w(a b c d e f g h i j)
  @numbers 1..10

  def new do
    coordinates = Enum.reduce(keys(), %{}, &put_coordinate/2)

    %__MODULE__{coordinates: coordinates}
  end

  def keys do
    for letter <- @letters,
        number <- @numbers,
      do: String.to_atom("#{letter}#{number}")
  end

  defp put_coordinate(key, map) do
    {:ok, coordinate} = Coordinate.Agent.start_link()

    Map.put_new(map, key, coordinate)
  end
end
