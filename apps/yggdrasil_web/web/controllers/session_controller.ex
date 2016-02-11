defmodule YggdrasilWeb.SessionController do
  use YggdrasilWeb.Web, :controller

  require Logger

  alias YggdrasilWeb.Session

  @invalid_username %{title: "Invalid username/password", 
                      detail: "Invalid username/password provided."}

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
