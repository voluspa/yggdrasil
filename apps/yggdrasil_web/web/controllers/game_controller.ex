defmodule YggdrasilWeb.GameController do
  use YggdrasilWeb.Web, :controller

  alias Yggdrasil.Game
  alias Yggdrasil.Repo, as: YggRepo

  def index(conn, _params) do
    games = YggRepo.all Game

    render conn, :show, data: games
  end
end
