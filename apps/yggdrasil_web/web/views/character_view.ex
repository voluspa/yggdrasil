defmodule YggdrasilWeb.CharacterView do
  use YggdrasilWeb.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :ext_id, :game_id]

  def type, do: "characters"
end
