defmodule Yggdrasil.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string

    timestamps
  end
end
