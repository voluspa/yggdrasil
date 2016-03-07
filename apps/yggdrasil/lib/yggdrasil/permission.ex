defmodule Yggdrasil.Permission do
  use Ecto.Schema

  @primary_key false
  schema "permissions" do
    field :name, :string, primary_key: true

    timestamps
  end
end
