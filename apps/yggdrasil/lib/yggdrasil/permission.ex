defmodule Yggdrasil.Permission do
  use Ecto.Schema

  @primary_key {:name, :string, []}
  schema "permissions" do
    timestamps
  end
end
