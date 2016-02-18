defmodule Yggdrasil.Room.Context do
  defstruct player: nil, actions: []

  import Yggdrasil.Message

  def notify_player(ctxt, message) do
    add_action ctxt, {:notify, ctxt.player, info(message)}
  end

  defp add_action(ctxt, action) do
    %{ctxt | :actions => [action | ctxt.actions]}
  end
end
