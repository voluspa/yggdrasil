defmodule Yggdrasil.SessionController do
  use Yggdrasil.Web, :controller

  require Logger

  alias Yggdrasil.Session

  @invalid_username %{title: "invalid username/password", 
                      detail: "invalid username/password provided"}

  def create(conn, params) do
    user_params = params["data"]["attributes"]
    case Session.login(user_params, Repo) do
      {:ok, user} ->
        conn
          |> Guardian.Plug.api_sign_in(user)
          |> render(:show, data: user)
      :error ->
        render conn, :errors, data: @invalid_username
    end
  end
end
