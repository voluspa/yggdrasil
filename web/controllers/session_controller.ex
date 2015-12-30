defmodule Yggdrasil.SessionController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User
  alias Yggdrasil.Session

  # go to client if logged in
  plug Yggdrasil.Plug.SkipIfAuthenticated when action in [:create, :new]
  # replaces empty strings with nil I believe
  # recommended to use mainly with html forms
  # also checks to see if it's there I think?!
  plug :scrub_params, "user" when action in [:create]

  # not sure why this can't be index...
  def new(conn, _params) do
    render conn, changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    case Session.login(user_params, Yggdrasil.Repo) do
      {:ok, user} ->
        conn
          |> put_session(:current_user, user)
          |> put_flash(:info, "You are now logged in") # probably can kill this
          |> redirect(to: client_path(conn, :index))
      :error ->
        conn
          |> put_flash(:error, "Invalid username or password")
          |> render("new.html", changeset: User.changeset(%User{}))
    end
  end

  def delete(conn, _) do
    delete_session(conn, :current_user)
      |> put_flash(:info, "You have been logged out")
      |> redirect(to: session_path(conn, :new))
  end
end
