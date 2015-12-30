defmodule Yggdrasil.Plug.SkipIfAuthenticated do
  import Plug.Conn
  import Yggdrasil.Router.Helpers
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, default) do
    if get_session(conn, :current_user) do
      conn |> redirect(to: client_path(conn, :index)) |> halt
    else
      conn
    end
  end
end
