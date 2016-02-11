defmodule YggdrasilWeb.RegistrationView do
  use YggdrasilWeb.Web, :view
  use JaSerializer.PhoenixView

  attributes [:username, :token]

  def type, do: "users"

  def token(_user, conn) do
    Guardian.Plug.current_token(conn)
  end
end
