defmodule Yggdrasil.RegistrationView do
  use Yggdrasil.Web, :view
  use JaSerializer.PhoenixView

  attributes [:username, :token]

  def token(_user, conn) do
    conn.assigns[:token]
  end
end
