defmodule YggdrasilWeb.GameController do
  use YggdrasilWeb.Web, :controller

  alias Yggdrasil.Game

  def index(conn, _params) do
    games = Repo.all Game

    render conn, :show, data: games
  end
end
