defmodule PlayerChannelTest do
  use Yggdrasil.ChannelCase
  alias Yggdrasil.PlayerChannel
  alias Yggdrasil.Message

  test "it returns an auth error if the wrong user tries to connect" do
    assert {:error, %{ error: "auth failure" }} = join_channel "1", "player:2"
  end

  test "it will join the player to the game when recieving a 'join_game'" do
    user_id = "20"

    join_game user_id

    assert Yggdrasil.Player.Registry.is_online(user_id, sync: true)
  end

  test "it notifies the player if another client issues a 'join_game'" do
    user_id = "20"

    join_game user_id

    # simulates a second client trying to join
    Task.async fn ->
      {:ok, _reply, socket2} = join_channel user_id
      push socket2, "join_game" 
    end

    assert_push "event", %Message{message: "Another client has tried to connect"}
  end

  test "it accepts commands as a 'player_cmd' event"  do
    user_id = "20"

    socket = join_game user_id

    push socket, "player_cmd", %{ "text" => "move east" }
    assert_push "event", %Message{}
  end

  test "it sends an 'error' event if the command fails to parse" do
    user_id = "20"

    socket = join_game user_id

    push socket, "player_cmd", %{ "text" => "I hope this doesn't work" }
    assert_push "error", %Message{}
  end

  defp join_channel(user_id, topic \\ nil)
  defp join_channel(user_id, topic) do
    if topic == nil, do: topic = "player:#{user_id}"

    socket(:nil, %{ user: user_id})
    |> subscribe_and_join(PlayerChannel, topic)
  end

  defp join_game(user_id) do
    {:ok, _reply, socket} = join_channel user_id
    ref = push socket, "join_game"
    assert_reply ref, :ok

    socket
  end
end
