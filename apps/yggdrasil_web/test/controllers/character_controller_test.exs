defmodule YggdrasilWeb.CharacterControllerTest do
  use YggdrasilWeb.ConnCase

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

    chars = Enum.map games, fn g ->
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

# test "get character by id", ctx do
#   path = api_character_path(conn, :show, ctx.user.id)

#   conn = ctx.conn
#   |> put_req_header("authorization", ctx.token)
#   |> get(path)

#   assert response_content_type(conn, :json) == @json_api_content_type_utf8
#   resp = response(conn, :ok)

#   assert resp == :ok
# end
end
