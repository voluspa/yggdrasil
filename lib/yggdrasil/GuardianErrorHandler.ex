defmodule Yggdrasil.GuardianErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  import Plug.Conn

  def unauthenticated(conn, _params) do
    conn
      # :unauthroized -> 401 covers both unauthenticated 
      # and unautherized requests from the client
      |> send_resp(:unauthorized, "")
  end

  def unauthorized(conn, _params) do
    conn
      |> send_resp(:unauthorized, "")
  end
end
