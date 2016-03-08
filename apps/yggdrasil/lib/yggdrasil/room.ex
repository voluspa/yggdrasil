defmodule Yggdrasil.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Yggdrasil.Room

  schema "rooms" do
    field :title, :string
    field :description, :string
    field :is_starting, :boolean, default: false
    timestamps
  end

  def create_changeset(params) do
    %Room{ }
    |> cast(params, ~w(title description), ~w())
    |> validate_length(:title, max: 120)
  end
end
