defmodule YggdrasilWeb.CharacterControllerTest do
  use YggdrasilWeb.ConnCase

  alias YggdrasilWeb.CharacterView
  alias Yggdrasil.{Repo, User, Game, Character}

  @user %{username: "tester",
          password: "password",
          password_confirmation: "password"}

  @json_api_content_type "application/vnd.api+json"
  @json_api_content_type_utf8 @json_api_content_type <> "; charset=utf-8"

  @invalid_charater "Invalid Character"

  setup %{conn: conn} do
    # need a user to gen a token for api
    {:ok, user} = %User{}
    |> User.create_changeset(@user)
    |> Repo.insert

    {:ok, user2} = %User{}
    |> User.create_changeset(%{@user | username: "tester2"})
    |> Repo.insert

    users = Enum.map [user, user2], fn u ->
      {:ok, token, _claims} = Guardian.encode_and_sign u, :token

      %{ model: u, token: token}
    end

    # set of games to have something to list
    games = Enum.map 1..2, fn n ->
      game = Game.changeset(%Game{}, %{"name" => "game#{n}",
                                       "description" => "game desc #{n}"})
      {:ok, game} = Repo.insert game

      game
    end

    users =  Enum.map users, fn u ->
      chars = Enum.flat_map games, fn g ->
        Enum.map 1..2, fn n ->
          char = Character.changeset(%Character{}, %{:name => "char #{g.name} #{u.model.id} #{n}",
                                                     :game_id => g.id,
                                                     :user_id => u.model.id})

          {:ok, char} = Repo.insert char

          char
        end
      end

      Map.put u, :chars, chars
    end

    conn = conn
      |> put_req_header("content-type", @json_api_content_type)
      |> put_req_header("accept", @json_api_content_type)

    {:ok, %{conn: conn, games: games, users: users}}
  end

  test "get /api/characters/char_id returns the correct character", ctx do
    user = Enum.at ctx.users, 0
    char = Enum.at user.chars, 0

    char_json = CharacterView.render("show.json", conn: %{}, data: char)
    |> Poison.encode!
    |> Poison.decode!

    assert user.model.id == char_json["data"]["attributes"]["user-id"]

    path = api_character_path(conn, :show, char.id)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8
    resp = Poison.decode! response(conn, :ok)

    assert resp == char_json
  end

  test "get /characters returns all characters for the user in the token provided", ctx do
    user = Enum.at ctx.users, 0 # first user has the token
    chars = Enum.sort_by user.chars, fn c -> c.id end

    chars_decoded = CharacterView.render("index.json", conn: %{}, data: chars)
    |> Poison.encode!
    |> Poison.decode!

    # assert all chracters stored in our context have the correct user_id
    assert Enum.all? chars_decoded["data"], fn cd -> user.model.id == cd["attributes"]["user-id"] end

    path = api_character_path(conn, :index)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8
    resp = Poison.decode! response(conn, :ok)
    # sort by id here as well.
    resp = %{ resp | "data" => Enum.sort_by(resp["data"], fn d -> d["id"] end) }

    # since all of our characters from context have the right user_id
    # if this succeeds then all the ones from the response also have the right user_id
    assert chars_decoded == resp
  end

  test "post /characters creates a character for the given user in the token provided", ctx do
    user = Enum.at ctx.users, 0
    game = Enum.at ctx.games, 0
    char = %{"name" => "unique_tester", "game-id" => game.id} # server fills in user_id

    json_api = %{data: %{type: "characters", attributes: char}}
    json = Poison.encode! json_api 

    path = api_character_path(conn, :create)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> post(path, json)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8

    resp = Poison.decode! response(conn, :ok)
    assert resp["data"]["attributes"] == Map.put(char, "user-id", user.model.id)
    # sort by id here as well.
  end

  test "post /characters creates a character for the given user in the token regardless of the user_id provided", ctx do
    user = Enum.at ctx.users, 0
    user2 = Enum.at ctx.users, 1
    game = Enum.at ctx.games, 0
    char = %{"name" => "unique_tester", "game-id" => game.id, "user-id" => user2.model.id} # server fills in user_id

    json_api = %{data: %{type: "characters", attributes: char}}
    json = Poison.encode! json_api 

    path = api_character_path(conn, :create)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> post(path, json)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8

    resp = Poison.decode! response(conn, :ok)
    assert resp["data"]["attributes"] == Map.put(char, "user-id", user.model.id)
    # sort by id here as well.
  end

  test "delete /characters/char_id removes the character specified for the given user in the token provided", ctx do
    user = Enum.at ctx.users, 0
    char = Enum.at user.chars, 0


    path = api_character_path(conn, :delete, char.id)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> delete(path)

    assert response(conn, :no_content)

    assert nil == Repo.get Character, char.id
  end

  test "delete /characters/char_id doesn't removes the character specified for another user instead of user in the token provided", ctx do
    user = Enum.at ctx.users, 0
    user2 = Enum.at ctx.users, 1
    char = Enum.at user2.chars, 0


    path = api_character_path(conn, :delete, char.id)

    conn = ctx.conn
    |> put_req_header("authorization", user.token)
    |> delete(path)

    assert response(conn, :ok) =~ @invalid_charater

    assert char == Repo.get Character, char.id
  end
end
