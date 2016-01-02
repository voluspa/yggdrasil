defmodule Yggdrasil.Session do
  alias Yggdrasil.User

  def login(%{"username" => nil}, _repo) do
    :error
  end

  def login(params, repo) do
    user = repo.get_by(User, username: String.downcase(params["username"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  # dummy_checkpw() used to prevent username enumeration
  # still burns time as if checking for a password
  defp authenticate(_user, nil) do
    Comeonin.Bcrypt.dummy_checkpw()
  end

  defp authenticate(nil, _password) do
    Comeonin.Bcrypt.dummy_checkpw()
  end

  defp authenticate(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.hash)
  end

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def logged_in?(conn), do: !!current_user(conn)
end
