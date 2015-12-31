defmodule Yggdrasil.Plug.Authenticate do
  import Plug.Conn
  import Yggdrasil.Router.Helpers
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    current_user = get_session(conn, :current_user)

    if current_user do
      # for now putting this here, slight change to initial way I approached it
      # the example in socket.js I would like to work toward
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      conn
        |> assign(:current_user, current_user)
        |> assign(:user_token, token)
    else
      conn
        |> put_flash(:error, "you need to be signed in to view this page")
        |> redirect(to: session_path(conn, :new))
        |> halt
    end
  end
end
