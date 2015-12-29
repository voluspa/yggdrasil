defmodule Yggdrasil.ClientController do
  use Yggdrasil.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
