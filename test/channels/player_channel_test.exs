defmodule PlayerChannelTest do
  use Yggdrasil.ChannelCase
  alias Yggdrasil.PlayerChannel
  alias Yggdrasil.Message

  test "it returns an auth error if the wrong user tries to connect" do
    assert {:error, %{ error: "auth failure" }} = join_channel "1", "player:2"
  end

  test "it will join the player to the game when recieving a 'join_game'" do
    user_id = "20"

    {:ok, _reply, socket} = join_channel user_id
    ref = push(socket, "join_game")
    assert_reply ref, :ok

    assert Yggdrasil.Player.Registry.is_online(user_id, sync: true)
  end

  test "it notifies the player if another client issues a 'join_game'" do
    user_id = "20"

    {:ok, _reply, socket1} = join_channel user_id

    ref = push(socket1, "join_game")
    assert_reply ref, :ok

    # simulates a second client trying to join
    Task.async fn ->
      {:ok, _reply, socket2} = join_channel user_id
      push(socket2, "join_game")
    end

    assert_push "event", %Message{message: "Another client has tried to connect"}
  end

  defp join_channel(user_id, topic \\ nil)
  defp join_channel(user_id, topic) do
    if topic == nil, do: topic = "player:#{user_id}"

    socket(:nil, %{ user: user_id})
    |> subscribe_and_join(PlayerChannel, topic)
  end
end
