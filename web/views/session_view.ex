defmodule Yggdrasil.SessionView do
  use Yggdrasil.Web, :view
  use JaSerializer.PhoenixView


  location :users_url
  attributes [:username, :token]

  # infers type based on module by default
  # which in this case would be Token, which
  # we don't want.
  def type, do: "users"

  def users_url(user, conn) do
    api_users_url(conn, :show, user.id)
  end

  def token(_user, conn) do
    Guardian.Plug.current_token(conn)
  end
end
