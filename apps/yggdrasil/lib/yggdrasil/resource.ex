defmodule Yggdrasil.Resource do
  use Ecto.Schema

  @primary_key {:name, :string, []}
  schema "resources" do
    timestamps
  end
end
