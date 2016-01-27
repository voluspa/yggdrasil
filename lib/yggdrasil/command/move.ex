defmodule Yggdrasil.Command.MoveCommand do
  defstruct exit: nil
end

defimpl Yggdrasil.Command, for: Yggdrasil.Command.MoveCommand do
  alias Yggdrasil.Message

  def execute(cmd, player) do
    Yggdrasil.Player.notify player, Message.info("You head towards #{cmd.exit}")
  end
end

