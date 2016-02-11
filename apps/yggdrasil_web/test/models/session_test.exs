defmodule YggdrasilWeb.SessionTest do
  use YggdrasilWeb.ConnCase

  alias YggdrasilWeb.Session
  alias Yggdrasil.User

  @user %User{:username => "tester"}

  @correct_username "tester"
  @correct_password "password"

  @incorrect_username "zzzzzzz"
  @incorrect_password "notpassword"

  defp setup_user() do
    user = %{
      :username => @correct_username,
      :password => @correct_password,
      :password_confirmation => @correct_password
    }

    User.create_changeset(%User{}, user)
      |> Repo.insert()
  end

  defp create_login_params(username, password) do
    %{"username" => username, "password" => password}
  end

  test "if user is in conn.assigns current_user returns the user" do
    conn = conn()
      |> assign(:current_user, @user)

    assert Session.current_user(conn) == @user
  end

  test "if user is not in conn.assigns current_user return nil" do
    conn = conn()

    assert Session.current_user(conn) == nil
  end

  test "if user is in conn.assigns logged_in? returns true " do
    conn = conn()
      |> assign(:current_user, @user)

    assert Session.logged_in?(conn)
  end

  test "if user is not in conn.assigns logged_in? returns false" do
    conn = conn()

    refute Session.logged_in?(conn)
  end

  test "login with correct username and password returns user" do
    {:ok, user} = setup_user()

    login_params = create_login_params(@correct_username, @correct_password)

    {:ok, user_new} = Session.login(login_params, Repo)
    assert user.id == user_new.id
  end

  test "login with correct username and incorrect password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(@correct_username, @incorrect_password)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with incorrect username and correct password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(@incorrect_username, @correct_password)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with incorrect username and incorrect password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(@incorrect_username, @incorrect_password)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with nil username and correct password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(nil, @correct_password)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with nil username and incorrect password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(nil, @incorrect_password)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with correct username and nil password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(@correct_username, nil)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with incorrect username and nil password returns error" do
    {:ok, _user} = setup_user()

    login_params = create_login_params(@incorrect_username, nil)
    assert :error == Session.login(login_params, Repo)
  end

  test "login with no username key but has correct password returns error" do
    {:ok, _user} = setup_user()

    login_params = Map.delete create_login_params(nil, @correct_password), "username"
    assert :error == Session.login(login_params, Repo)
  end

  test "login with no username key but has incorrect password returns error" do
    {:ok, _user} = setup_user()

    login_params = Map.delete create_login_params(nil, @incorrect_password), "username"
    assert :error == Session.login(login_params, Repo)
  end

  test "login with correct username but has no password key returns error" do
    {:ok, _user} = setup_user()

    login_params = Map.delete create_login_params(@correct_username, nil), "password"
    assert :error == Session.login(login_params, Repo)
  end

  test "login with incorrect username but has no password key returns error" do
    {:ok, _user} = setup_user()

    login_params = Map.delete create_login_params(@incorrect_username, nil), "password"
    assert :error == Session.login(login_params, Repo)
  end

  test "login with no username or password keys returns error" do
    {:ok, _user} = setup_user()

    login_params = %{}
    assert :error == Session.login(login_params, Repo)
  end

  test "login with nil login_params returns error" do
    {:ok, _user} = setup_user()

    assert :error == Session.login(nil, Repo)
  end
end
