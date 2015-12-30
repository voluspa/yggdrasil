defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  import Ecto.Changeset, only: [put_change: 3]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Yggdrasil.User

  # if logged in, go straight to client
  plug Yggdrasil.Plug.RedirectIfAuthenticated
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    result = changeset
      |> put_change(:hash, hashpwsalt(changeset.params["password"]))
      |> Repo.insert

    case result do 
      {:ok, new_user} -> 
        conn
          |> put_flash(:info, "Succesfully registered and logged in")
          |> put_session(:current_user, new_user)
          |> redirect(to: client_path(conn, :index))
      {:error, result_changeset} ->
        render conn, "new.html", changeset: result_changeset
    end
  end
end
