defmodule Yggdrasil.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :name, :string

    timestamps
  end
end
