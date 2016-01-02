defmodule Yggdrasil.RedirectIfAuthenticatedTest do
  use Yggdrasil.ConnCase

  alias Yggdrasil.User
  alias Yggdrasil.Plug.RedirectIfAuthenticated

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

  test "if user is not in session the connection is not halted", %{conn: conn} do
    conn = conn
      |> without_user_in_session(@dummy_path)
      |> RedirectIfAuthenticated.call([])

    refute conn.halted
  end

  test "if user is in session redirect to /client and halt", %{conn: conn} do
    conn = conn
      |> with_user_in_session(@dummy_path)
      |> RedirectIfAuthenticated.call([])

    assert client_path(conn, :index) == redirected_to(conn)
    assert conn.halted
  end

  test "RedirectIfAuthenticated.init returns what was passed in" do
    assert RedirectIfAuthenticated.init([]) == []
  end
end
