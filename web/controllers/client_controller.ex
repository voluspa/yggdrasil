defmodule Yggdrasil.ClientController do
  use Yggdrasil.Web, :controller

  plug Yggdrasil.Plug.Authenticate

  def index(conn, _params) do
    render conn, "index.html"
  end
end
