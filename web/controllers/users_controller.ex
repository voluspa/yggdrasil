defmodule Yggdrasil.UsersController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  def index(conn, _params) do
    render conn, model: Repo.all(User)
  end

  def show(conn, params) do
    render conn, model: Repo.get!(User, params["id"])
  end

  def create(conn, params) do
    changeset = User.create_changeset(%User{}, params["data"]["attributes"])

    case Repo.insert(changeset) do
      {:ok, new_user} ->
        token = Phoenix.Token.sign(conn, "api_token", new_user.id)
        # treat the user like they are logged in now
        # and return a token for the client to use
        conn = assign(conn, :token, token)

        render conn, "show.json", data: new_user
      {:error, err_changeset} ->
        render conn, "errors.json", data: err_changeset
    end
  end
end
