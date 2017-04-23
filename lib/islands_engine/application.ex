defmodule IslandsEngine.Application do
  use Application

  import Supervisor.Spec, warn: false

  def start(_type, _args),
    do: Supervisor.start_link(children(), opts())

  defp children do
    [

    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name:     IslandsEngine.Supervisor,
    ]
  end
end
