defmodule Yggdrasil.RoleResource do
  use Ecto.Schema

  @primary_key false
  schema "roles_resources" do
    field :resource, :string
    field :permission, :string

    belongs_to :role, Yggdrasil.Role

    timestamps
  end
end
