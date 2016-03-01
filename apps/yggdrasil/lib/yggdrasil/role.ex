defmodule Yggdrasil.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    has_many :role_resources, Yggdrasil.RoleResource

    timestamps
  end
end
