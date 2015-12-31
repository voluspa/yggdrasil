defmodule Yggdrasil.AuthenticateTest do
  use Yggdrasil.ConnCase

  alias Yggdrasil.User
  alias Yggdrasil.Plug.Authenticate

  @user %User{:username => "tester"}

  # taken from here
  # https://github.com/phoenixframework/phoenix/blob/v1.1.1/test/support/router_helper.exs
  # needed to put the user in session
  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "yadayada",
    signing_salt: "yadayada"
  )

  def with_session(conn) do
    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(@session)
    |> Plug.Conn.fetch_session()
  end

  def with_user_session(conn, path) do
    conn
      |> bypass_through(Yggdrasil.Router, [:browser])
      |> with_session
      |> get(path)
      |> put_session(:current_user, @user)
  end

  test "if user is not in session redirect to root and halt" do
    conn = conn()
      |> bypass_through(Yggdrasil.Router, [:browser])
      |> with_session
      |> get("/secure")
      |> Authenticate.call([])

    assert "/" == redirected_to(conn)
    assert conn.halted
  end

  test "if user is not in session connection halted and user is not in assigns" do
    conn = conn()
      |> bypass_through(Yggdrasil.Router, [:browser])
      |> with_session
      |> get("/secure")
      |> Authenticate.call([])

    assert conn.halted
    username = conn.assigns[:current_user]
    refute username
  end

  test "if user is not in session connection halted and token is not in assigns" do
    conn = conn()
      |> bypass_through(Yggdrasil.Router, [:browser])
      |> with_session
      |> get("/secure")
      |> Authenticate.call([])

    assert conn.halted
    token = conn.assigns[:token]
    refute token
  end

  test "if user is in session connection is not halted" do
    conn = conn()
      |> with_user_session("/secure")
      |> Authenticate.call([])

    refute conn.halted
  end

  test "if user is in session :curruent_user is assigned" do
    conn = conn()
      |> with_user_session("/secure")
      |> Authenticate.call([])

    refute conn.halted
    assert conn.assigns.current_user == @user
  end

  test "if user is in session :curruent_user is assigned and valid" do
    conn = conn()
      |> with_user_session("/secure")
      |> Authenticate.call([])

    refute conn.halted

    # token will be nil if key isn't present
    token = conn.assigns[:user_token]
    assert token
    assert Phoenix.Token.verify(conn, "user socket", token, max_age: 1209600)
  end
end
