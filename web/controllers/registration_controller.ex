defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  import Ecto.Changeset, only: [put_change: 3]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Yggdrasil.User

  # if logged in, go straight to client
  plug Yggdrasil.Plug.SkipIfAuthenticated
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    # this whole block needs to be simplified
    # copied from various sources
    if changeset.valid? do
      result = changeset
        |> put_change(:hash, hashpwsalt(changeset.params["password"]))
        |> Repo.insert

      # need to check after insert, username has unique constraint and only will fire after insert
      case result do 
        {:ok, new_user} -> 
          conn
            |> put_flash(:info, "Succesfully registered and logged in")
            |> put_session(:current_user, new_user)
            |> redirect(to: client_path(conn, :index))
        {:error, result_changeset} ->
          render conn, "new.html", changeset: result_changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end
end
