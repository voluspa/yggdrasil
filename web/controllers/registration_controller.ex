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
        token = Phoenix.Token.sign(conn, "api_token", new_user.id)
        # treat the user like they are logged in now
        # and return a token for the client to use
        conn
          |> assign(:token, token)
          |> put_flash(:info, "Succesfully registered and logged in")
          |> put_session(:current_user, new_user)
          |> redirect(to: client_path(conn, :index))
      {:error, err_changeset} ->
        render conn, "new.html", changeset: err_changeset
    end
  end
end
