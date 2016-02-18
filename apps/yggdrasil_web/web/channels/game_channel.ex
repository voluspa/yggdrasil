defmodule YggdrasilWeb.GameChannel do
  use YggdrasilWeb.Web, :channel

  def join("game:lobby", _message, socket) do
    socket = assign socket, :player_topic, "player:#{socket.assigns.user}"
    {:ok, %{ topic: socket.assigns.player_topic }, socket}
  end
end
