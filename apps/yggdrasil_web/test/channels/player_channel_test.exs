defmodule PlayerChannelTest do
  use YggdrasilWeb.ChannelCase
  alias YggdrasilWeb.{PlayerChannel, User}
  alias Yggdrasil.{Message, Game, Character}

  @user   %{username: "tester",
            password: "test123", 
            password_confirmation: "test123" }

  @game   %{name: "abcdef", description: "abcdefghi"}

  setup _context do
    {:ok, user} = %User{}
    |> User.create_changeset(@user)
    |> Repo.insert

    {:ok, game} = %Game{}
    |> Game.changeset(@game)
    |> YggRepo.insert

    character = %{name: "testchar", ext_id: user.id, game_id: game.id}

    {:ok, char} = %Character{}
    |> Character.changeset(character)
    |> YggRepo.insert

    {:ok, %{char: char, user: user}}
  end

  test "it returns an auth error if the wrong user tries to connect" do
    ctx = %{user: %User{id: 0}, char: %Character{id: 0}}
    assert {:error, %{ error: "auth failure" }} = join_channel ctx
  end

  test "it will join the player to the game when recieving a 'join_game'", ctx do
    join_game ctx

    assert Yggdrasil.Player.Registry.is_online(ctx.char.id, sync: true)
  end

  test "it notifies the player if another client issues a 'join_game'", ctx do
    join_game ctx

    # simulates a second client trying to join
    Task.async fn ->
      {:ok, _reply, socket2} = join_channel ctx
      push socket2, "join_game"
    end

    assert_push "event", %Message{message: "Another client has tried to connect"}
  end

  test "it accepts commands as a 'player_cmd' event", ctx do
    socket = join_game ctx

    push socket, "player_cmd", %{ "text" => "move east" }
    assert_push "event", %Message{}
  end

  test "it sends an 'error' event if the command fails to parse", ctx do
    socket = join_game ctx

    push socket, "player_cmd", %{ "text" => "I hope this doesn't work" }
    assert_push "error", %Message{}
  end

  defp join_channel(%{user: user, char: char}) do
    socket(:nil, %{ user: user.id})
    |> subscribe_and_join(PlayerChannel, "player:#{char.id}")
  end

  defp join_game(ctx) do
    {:ok, _reply, socket} = join_channel ctx
    ref = push socket, "join_game"
    assert_reply ref, :ok

    socket
  end
end
