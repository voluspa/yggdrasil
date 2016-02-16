defmodule Yggdrasil.GameView do
  use Yggdrasil.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :description]

  def type, do: "games"
end
