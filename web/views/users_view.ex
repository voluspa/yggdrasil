defmodule Yggdrasil.UsersView do
  use Yggdrasil.Web, :view
  use JaSerializer.PhoenixView

  location :users_url
  attributes [:username, :token]

  def users_url(user, conn) do
    api_users_url(conn, :show, user.id)
  end

  def token(_user, conn) do
    conn.assigns[:token]
  end
end
