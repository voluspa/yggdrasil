defmodule YggdrasilWeb.CharacterControllerTest do
  use YggdrasilWeb.ConnCase

  alias YggdrasilWeb.CharacterView
  alias Yggdrasil.{Repo, User, Game, Character}

  @user %{username: "tester",
          password: "password",
          password_confirmation: "password"}

  @json_api_content_type "application/vnd.api+json"
  @json_api_content_type_utf8 @json_api_content_type <> "; charset=utf-8"

  setup %{conn: conn} do
    # need a user to gen a token for api
    {:ok, user} = %User{}
    |> User.create_changeset(@user)
    |> Repo.insert

    #api token
    {:ok, token, _claims} = Guardian.encode_and_sign user, :token


    # set of games to have something to list
    games = Enum.map 1..2, fn n ->
      game = Game.changeset(%Game{}, %{"name" => "game#{n}",
                                       "description" => "game desc #{n}"})
      {:ok, game} = Repo.insert game

      game
    end

    chars = Enum.flat_map games, fn g ->
      Enum.map 1..2, fn n ->
        char = Character.changeset(%Character{}, %{:name => "char #{g.name} #{n}",
                                                   :game_id => g.id,
                                                   :user_id => user.id})

        {:ok, char} = Repo.insert char

        char
      end
    end

    conn = conn
      |> put_req_header("content-type", @json_api_content_type)
      |> put_req_header("accept", @json_api_content_type)

    {:ok, %{conn: conn, chars: chars, games: games, user: user, token: token}}
  end

  test "get /api/characters/char_id returns the correct character", ctx do
    char = Enum.at ctx.chars, 0

    char_json = CharacterView.render("show.json", conn: %{}, data: char)
    |> Poison.encode!
    |> Poison.decode!

    path = api_character_path(conn, :show, char.id)

    conn = ctx.conn
    |> put_req_header("authorization", ctx.token)
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8
    resp = Poison.decode! response(conn, :ok)

    assert resp == char_json
  end

  test "get /characters returns all characters for user", ctx do
    # ensure some order to the list when comparing below.
    chars = Enum.sort_by ctx.chars, fn c -> c.id end

    # this looks weird but the view returns a map of the data to be encoded
    # however it still has atoms as keys, where as the resp below decoded
    # has strings as keys so by encoding and decoding ew have the same map
    # decoding the response will have
    chars_decoded = CharacterView.render("index.json", conn: %{}, data: chars)
    |> Poison.encode!
    |> Poison.decode!

    path = api_character_path(conn, :index)

    conn = ctx.conn
    |> put_req_header("authorization", ctx.token)
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8
    resp = Poison.decode! response(conn, :ok)
    # sort by id here as well.
    resp = %{ resp | "data" => Enum.sort_by(resp["data"], fn d -> d["id"] end) }

    assert chars_decoded == resp
  end
end
