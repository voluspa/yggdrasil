defmodule Yggdrasil.GameChannel do
  use Yggdrasil.Web, :channel

  require Logger

  def join("game:lobby", _message, socket) do
    Logger.info "client connected"
    {:ok, socket}
  end

  def handle_in("user_cmd", message, socket) do
    Logger.info "client sent a message"
    push socket, "event", message
    {:noreply, socket}
  end
end
