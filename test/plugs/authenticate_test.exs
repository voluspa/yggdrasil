defmodule Yggdrasil.AuthenticateTest do
  use Yggdrasil.ConnCase

  alias Yggdrasil.User
  alias Yggdrasil.Plug.Authenticate

  @user %User{:username => "tester"}
  @dummy_path "/notrealpath"

  def without_user_in_session(conn, path) do
    conn
      |> bypass_through(Yggdrasil.Router, [:browser])
      |> get(path)
  end

  def with_user_in_session(conn, path) do
    conn
      |> without_user_in_session(path)
      |> put_session(:current_user, @user)
  end

  test "if user is not in session redirect to root and halt", %{conn: conn} do
    conn = conn
      |> without_user_in_session(@dummy_path)
      |> Authenticate.call([])

    assert "/" == redirected_to(conn)
    assert conn.halted
  end

  test "if user is not in session connection halted and user is not in assigns", %{conn: conn} do
    conn = conn
      |> without_user_in_session(@dummy_path)
      |> Authenticate.call([])

    assert conn.halted
    username = conn.assigns[:current_user]
    refute username
  end

  test "if user is not in session connection halted and token is not in assigns", %{conn: conn} do
    conn = conn
      |> without_user_in_session(@dummy_path)
      |> Authenticate.call([])

    assert conn.halted
    token = conn.assigns[:token]
    refute token
  end

  test "if user is in session connection is not halted", %{conn: conn} do
    conn = conn
      |> with_user_in_session(@dummy_path)
      |> Authenticate.call([])

    refute conn.halted
  end

  test "if user is in session :curruent_user is assigned", %{conn: conn} do
    conn = conn
      |> with_user_in_session(@dummy_path)
      |> Authenticate.call([])

    refute conn.halted
    assert conn.assigns.current_user == @user
  end

  test "if user is in session :curruent_user is assigned and valid", %{conn: conn} do
    conn = conn
      |> with_user_in_session(@dummy_path)
      |> Authenticate.call([])

    refute conn.halted

    # token will be nil if key isn't present
    token = conn.assigns[:user_token]
    assert token
    assert Phoenix.Token.verify(conn, "user socket", token, max_age: 1209600)
  end
end
