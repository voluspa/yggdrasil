defmodule Yggdrasil.Command.MoveCommand do
  defstruct exit: nil

  defimpl Yggdrasil.Command, for: Yggdrasil.Command.MoveCommand do
    import Yggdrasil.Room.Context

    def execute(cmd, room_ctxt) do
      room_ctxt
      |> notify_player("You head towards #{cmd.exit}")
    end
  end
end

