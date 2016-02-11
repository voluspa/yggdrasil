defmodule YggdrasilWeb.RegistrationControllerTest do
  use YggdrasilWeb.ConnCase

  alias Yggdrasil.Repo
  alias Yggdrasil.User

  @json_api_content_type "application/vnd.api+json"
  @json_api_content_type_utf8 @json_api_content_type <> "; charset=utf-8"

  @good_user %{username: "tester",
               password: "password",
               password_confirmation: "password"}

  @good_user_bad_pw %{username: "tester",
               password: "passwas",
               password_confirmation: "password"}

  @bad_user %{username: "dont_exist",
               password: "password",
               password_confirmation: "password"}

  @has_error_details "detail"
  @invalid_doc "Invalid document."
  @username_taken "has already been taken"

  defp create_user do
    {:ok, _new_user} = Repo.insert(User.create_changeset(%User{}, @good_user))
  end

  defp post_user_json(conn, user_json) do
    path = api_auth_registration_path(conn, :create)

    conn = conn
      |> put_req_header("content-type", @json_api_content_type)
      |> put_req_header("accept", @json_api_content_type)
      |> post(path, user_json)

    assert response_content_type(conn, :json) == @json_api_content_type_utf8

    conn
  end

  defp serialize_and_post_user_json(conn, user_params) do
    post_user_json(conn, serialize_user(user_params))
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

  test "user registration with valid user params returns user", %{conn: conn} do
    conn = serialize_and_post_user_json(conn, @good_user)
    res_user = Poison.decode! response(conn, :ok)

    user_id = res_user["data"]["id"]
    assert strip_token(res_user) == format_user(Repo.get(User, user_id))
  end

  test "user registration with valid user params returns valid token", %{conn: conn} do
    conn = serialize_and_post_user_json(conn, @good_user)

    res_user = Poison.decode! response(conn, :ok)
    token = res_user["data"]["attributes"]["token"]
    assert token

    {:ok, claims} = Guardian.decode_and_verify(token)

    user_id = res_user["data"]["id"]

    assert Guardian.serializer.from_token(claims["sub"]) == Repo.get(User, user_id)
  end

  test "user registration with password mismatch fails", %{conn: conn} do
    conn = serialize_and_post_user_json(conn, @good_user_bad_pw)

    assert response(conn, :ok) =~ @has_error_details
  end

  test "user registration with an already taken username fails" do
    _user = create_user

    conn = serialize_and_post_user_json(conn, @good_user)

    assert response(conn, :ok) =~ @username_taken
  end

  test "user nil attributes returns error", %{conn: conn} do
    conn = serialize_and_post_user_json(conn, nil)

    assert response(conn, :ok) =~ @invalid_doc
  end

  test "user no document returns invalid document", %{conn: conn} do
    conn = post_user_json(conn, nil)

    assert response(conn, :ok) =~ @invalid_doc
  end
end
