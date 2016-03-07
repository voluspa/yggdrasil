defmodule Yggdrasil.Resource do
  use Ecto.Schema

  @primary_key false
  schema "resources" do
    field :name, :string, primary_key: true

    timestamps
  end
end
