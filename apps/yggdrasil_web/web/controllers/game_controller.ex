defmodule YggdrasilWeb.GameController do
  use YggdrasilWeb.Web, :controller

  alias Yggdrasil.Game
  alias YggdrasilWeb.EnsurePermission

  plug EnsurePermission, [character: [:read]] when action in [:index]

  def index(conn, _params) do
    games = Repo.all Game

    render conn, :show, data: games
  end
end
