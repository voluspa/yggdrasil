defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  # if logged in, go straight to client
  plug Yggdrasil.Plug.RedirectIfAuthenticated
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    render conn, changeset: User.create_changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.create_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, new_user} -> 
        conn
          |> put_flash(:info, "Succesfully registered and logged in")
          |> put_session(:current_user, new_user)
          |> redirect(to: client_path(conn, :index))
      {:error, err_changeset} ->
        render conn, "new.html", changeset: err_changeset
    end
  end
end
