defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  def create(conn, params) do
    changeset = User.create_changeset(%User{}, params["data"]["attributes"])

    case Repo.insert(changeset) do
      {:ok, new_user} ->
        conn
          |> Guardian.Plug.api_sign_in(new_user)
          |> render(:show, data: new_user)
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end
end
