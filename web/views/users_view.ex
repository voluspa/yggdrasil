defmodule Yggdrasil.UsersView do
  use Yggdrasil.Web, :view
  use JaSerializer.PhoenixView

  location :users_url
  attributes [:username, :hash]

  def users_url(user, conn) do
    api_users_url(conn, :show, user.id)
  end
end
