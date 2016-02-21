defmodule YggdrasilWeb.GameControllerTest do
  use YggdrasilWeb.ConnCase

  alias Yggdrasil.{Repo, User, Game}

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
    games = Enum.map 1..10, fn n ->
      game = Game.changeset(%Game{}, %{"name" => "game#{n}",
                                       "description" => "game desc #{n}"})
      {:ok, game} = Repo.insert game

      game
    end

    conn = conn
      |> put_req_header("content-type", @json_api_content_type)
      |> put_req_header("accept", @json_api_content_type)

    {:ok, %{conn: conn, games: games, user: user, token: token}}
  end

  defp compare_game_lists(resp, games) do
    games_resp = Poison.decode! resp

    api_games = Enum.map games_resp["data"], fn g ->
      attrs = g["attributes"]
      {id, _remainder} = Integer.parse g["id"]

      game = Map.put attrs, "id", id
      for {key, val} <- game, into: %{}, do: {String.to_atom(key), val}
    end

    db_games = Enum.map games, fn g ->
      g
      |> Map.from_struct
      |> Map.drop([:inserted_at, :updated_at, :__meta__])
    end

    db_games == api_games
  end

  test "access denied (401) if auth header isn't present", ctx do
    path = api_game_path(conn, :index)
    conn = ctx.conn
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type
    assert response(conn, 401)
  end

  test "all games are listed", ctx do
    path = api_game_path(conn, :index)
    conn = ctx.conn
    |> put_req_header("authorization", ctx.token)
    |> get(path)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8
    games_match = compare_game_lists(response(conn, :ok), ctx.games)

    assert games_match
  end
end
