defmodule Yggdrasil.GameController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.Game

  def index(conn, _params) do
    games = Repo.all Game

    render conn, :show, data: games
  end
end
