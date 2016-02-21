defmodule YggdrasilWeb.GameView do
  use YggdrasilWeb.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :description]

  def type, do: "games"
end
