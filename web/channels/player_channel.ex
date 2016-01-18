defmodule Yggdrasil.PlayerChannel do
  use Yggdrasil.Web, :channel
  alias Yggdrasil.Player
  alias Yggdrasil.Endpoint
  alias Yggdrasil.Message
  require Logger

  def join("player:" <> user_id = topic, _message, socket) do
    if socket.assigns.user == user_id do
      {:ok, socket}
    else
      {:error, %{ error: "auth failure"} }
    end
  end

  def handle_in("join_game", _message, socket) do
    user_id = socket.assigns.user
    player_topic = socket.topic
    push_msg = fn (payload) ->
      Endpoint.broadcast! player_topic, "event", payload
    end

    case Player.join_game user_id, self, push_msg do
      {:ok, _pid} ->
        {:reply, :ok,  socket}
      {:error, :already_registered} ->
        Player.notify(user_id,
          Message.info("Another client has tried to connect"))

        push socket, "event", Message.error(:already_registered)
        {:stop, {:shutdown, :player_online}, socket}
    end
  end

  def handle_in("player_cmd", %{ "text" => text }, socket) do
    Player.run_cmd(socket.assigns.user, Message.command(text))
    {:noreply, socket}
  end
end
