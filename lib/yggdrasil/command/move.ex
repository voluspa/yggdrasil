defmodule Yggdrasil.Command.MoveCommand do
  defstruct exit: nil
end

defimpl Yggdrasil.Command, for: Yggdrasil.Command.MoveCommand do
  def execute(player, cmd) do
    Yggdrasil.Player.notify player, "You head towards #{cmd.exit}"
  end
end

