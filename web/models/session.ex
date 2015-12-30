defmodule Yggdrasil.Session do
  alias Yggdrasil.User

  def login(%{"username" => nil}, repo) do
    :error
  end

  def login(params, repo) do
    user = repo.get_by(User, username: String.downcase(params["username"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  defp authenticate(_user, nil) do
    false
  end

  defp authenticate(nil, _password) do
    false
  end

  defp authenticate(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.hash)
  end

  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end

  def logged_in?(conn), do: !!current_user(conn)
end
