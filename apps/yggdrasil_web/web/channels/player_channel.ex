defmodule YggdrasilWeb.PlayerChannel do
  use YggdrasilWeb.Web, :channel

  alias YggdrasilWeb.Endpoint
  alias Yggdrasil.{Player, Message, Command.Parser, Character}

  require Logger

  def join("player:" <> char_id = _topic, _message, socket) do
    user_id = socket.assigns.user

    char = Repo.one from c in Character,
                    where: c.id == ^char_id and c.user_id == ^user_id,
                    select: c

    if char do
      socket = assign socket, :character, char
      {:ok, socket}
    else
      {:error, %{ error: "auth failure"} }
    end
  end

  def handle_in("join_game", _message, socket) do
    char = socket.assigns.character
    player_topic = socket.topic
    push_msg = fn (payload) ->
      Endpoint.broadcast! player_topic, "event", payload
    end

    case Player.join_game char.id, self, push_msg do
      {:ok, _pid} ->
        {:reply, :ok,  socket}
      {:error, :already_registered} ->
        Player.notify(char.id,
          Message.info("Another client has tried to connect"))

        push socket, "event", Message.error(:already_registered)
        {:stop, {:shutdown, :player_online}, socket}
    end
  end

  def handle_in("player_cmd", %{ "text" => text }, socket) do
    case Parser.parse(text) do
      {:ok, cmd} ->
        Player.run_cmd(socket.assigns.character.id, cmd)
        {:noreply, socket}
      {:error, reason} ->
        broadcast! socket, "error", Message.error(reason)
        {:noreply, socket}
    end
  end
end
