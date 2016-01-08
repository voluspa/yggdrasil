defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  def create(conn, params) do
    changeset = User.create_changeset(%User{}, params["data"]["attributes"])

    case Repo.insert(changeset) do
      {:ok, new_user} ->
        token = Phoenix.Token.sign(conn, "api_token", new_user.id)
        conn = assign(conn, :token, token)
        render conn, "show.json", data: new_user
      {:error, err_changeset} ->
        render conn, "errors.json", data: err_changeset
    end
  end
end
