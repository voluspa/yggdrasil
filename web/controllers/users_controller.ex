defmodule Yggdrasil.UsersController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  def index(conn, _params) do
    render conn, model: Repo.all(User)
  end

  def show(conn, params) do
    render conn, model: Repo.get!(User, params["data"]["id"])
  end

  def create(conn, params) do
    changeset = User.create_changeset(%User{}, params["data"]["attributes"])

    case Repo.insert(changeset) do
      {:ok, new_user} ->
        render conn, :show, data: new_user
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end
end
