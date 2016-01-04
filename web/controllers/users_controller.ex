defmodule Yggdrasil.UsersController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  def index(conn, _params) do
    render conn, model: Repo.all(User)
  end

  def show(conn, params) do
    render conn, model: Repo.get!(User, params["id"])
  end
end
