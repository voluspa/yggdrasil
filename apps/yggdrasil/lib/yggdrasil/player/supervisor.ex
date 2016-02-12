defmodule Yggdrasil.Player.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end

  def init([]) do
    children = [
      worker(Yggdrasil.Player, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def add_player(char_id, args) do
    Supervisor.start_child(__MODULE__, [char_id | args])
  end
end
