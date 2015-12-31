defmodule Yggdrasil.SessionTest do
  use Yggdrasil.ConnCase

  alias Yggdrasil.Session
  alias Yggdrasil.User

  @user %User{:username => "tester"}

  test "if user is in conn.assigns current_user returns the user" do
    conn = conn()
      |> assign(:current_user, @user)

    assert Session.current_user(conn) == @user
  end

  test "if user is not in conn.assigns return nil" do
    conn = conn()

    assert Session.current_user(conn) == nil
  end
end
