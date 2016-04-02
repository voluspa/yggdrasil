defmodule Yggdrasil.RolePermission do
  use Ecto.Schema

  @primary_key false
  schema "roles_permissions" do
    field :resource, :string
    field :permission, :string

    belongs_to :role, Yggdrasil.Role

    timestamps
  end
end
