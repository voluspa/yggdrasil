defmodule Yggdrasil.TokenController do
  use Yggdrasil.Web, :controller

  require Logger

  alias Yggdrasil.Session

  def create(conn, params) do
    user_params = params["data"]["attributes"]
    Logger.debug inspect user_params
    case Session.login(user_params, Repo) do
      {:ok, user} ->
        token = Phoenix.Token.sign(conn, "api_token", user.id)
        conn
          |> assign(:token, token)
          |> render("show.json", data: user)
      :error ->
        invalid_username = %{title: "invalid username/password", 
                             detail: "invalid username/password provided"}

        render conn, "errors.json", data: invalid_username
    end
  end
end
