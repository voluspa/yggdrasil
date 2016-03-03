defmodule YggdrasilWeb.SessionControllerTest do
  use YggdrasilWeb.ConnCase

  alias Yggdrasil.Repo
  alias Yggdrasil.User

  @json_api_content_type "application/vnd.api+json"
  @json_api_content_type_utf8 @json_api_content_type <> "; charset=utf-8"

  @good_user %{username: "tester",
               password: "password"}

  @good_user_bad_pw %{username: "tester",
               password: "passwas"}

  @bad_user %{username: "dont_exist",
               password: "password"}

  @invalid_username "Invalid username/password"

  defp create_user do
    db_user = Map.put @good_user, :password_confirmation, @good_user.password
    {:ok, new_user} = Repo.insert(User.create_changeset(%User{}, db_user))

    new_user
  end

  defp post_user_json(conn, user_params) do
    user = create_user()
    user_json = serialize_user(user_params)
    path = api_auth_session_path(conn, :create)

    conn = conn
      |> put_req_header("content-type", @json_api_content_type)
      |> put_req_header("accept", @json_api_content_type)
      |> post(path, user_json)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8

    {:ok, user, conn}
  end

  defp serialize_user(user) do
    json_api_doc = %{ data: %{ type: "users", attributes: user }}

    Poison.encode! json_api_doc
  end

  defp format_user(user) do
    %{"data" => %{"attributes" => %{"username" => user.username},
                  "id" => "#{user.id}",
                  "type" => "users"},
      "jsonapi" => %{"version" => "1.0"}}
  end

  # can't generate token to compare against
  defp strip_token(user) do
    new_attrs = Map.delete user["data"]["attributes"], "token"

    %{user | "data" => %{user["data"] | "attributes" => new_attrs }}
  end

  # -- tests

  test "user login with correct credentials returns the user", %{conn: conn} do
    {:ok, user, conn} = post_user_json(conn, @good_user)

    res_user = Poison.decode! response(conn, :ok)
    assert strip_token(res_user) == format_user(user)
  end

  test "user login with correct credentials returns a valid token", %{conn: conn} do
    {:ok, user, conn} = post_user_json(conn, @good_user)

    res_user = Poison.decode! response(conn, :ok)
    token = res_user["data"]["attributes"]["token"]
    assert token

    {:ok, claims} = Guardian.decode_and_verify(token)

    # user above contains some extra keys from the creation
    # so need to test against a fresh db record.
    user = User
    |> User.with_roles
    |> Repo.get!(user.id)

    assert Guardian.serializer.from_token(claims["sub"]) == {:ok, user}
  end

  test "user login correct username but bad password returns error", %{conn: conn} do
    {:ok, _user, conn} = post_user_json(conn, @good_user_bad_pw)

    assert response(conn, :ok) =~ @invalid_username
  end

  test "user login bad username and password returns error", %{conn: conn} do
    {:ok, _user, conn} = post_user_json(conn, @bad_user)

    assert response(conn, :ok) =~ @invalid_username
  end

  test "user login no username but includes password returns error", %{conn: conn} do
    {:ok, _user, conn} = post_user_json(conn, Map.delete(@bad_user, :username))

    assert response(conn, :ok) =~ @invalid_username
  end

  test "user login no username or password returns error", %{conn: conn} do
    {:ok, _user, conn} = post_user_json(conn, %{})

    assert response(conn, :ok) =~ @invalid_username
  end

  test "user nil attributes returns error", %{conn: conn} do
    {:ok, _user, conn} = post_user_json(conn, nil)

    assert response(conn, :ok) =~ @invalid_username
  end
end
