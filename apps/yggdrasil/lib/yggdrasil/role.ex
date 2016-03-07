defmodule Yggdrasil.Role do
  use Ecto.Schema

  schema "roles" do
    field :name, :string
    has_many :role_permissions, Yggdrasil.RolePermission

    timestamps
  end
end
