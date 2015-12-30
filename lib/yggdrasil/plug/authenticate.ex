defmodule Yggdrasil.Plug.Authenticate do
  import Plug.Conn
  import Yggdrasil.Router.Helpers
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, default) do
    current_user = get_session(conn, :current_user)

    if current_user do
      assign(conn, :current_user, current_user)
    else
      conn
        |> put_flash(:error, "you need to be signed in to view this page")
        |> redirect(to: session_path(conn, :new))
        |> halt
    end
  end
end
