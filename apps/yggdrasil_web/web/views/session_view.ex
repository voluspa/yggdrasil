defmodule YggdrasilWeb.SessionView do
  use YggdrasilWeb.Web, :view
  use JaSerializer.PhoenixView

  attributes [:username, :token]

  # infers type based on module by default
  # which in this case would be Token, which
  # we don't want.
  def type, do: "users"

  def token(_user, conn) do
    Guardian.Plug.current_token(conn)
  end
end
