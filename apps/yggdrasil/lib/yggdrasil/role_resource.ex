defmodule Yggdrasil.RoleResource do
  use Ecto.Schema

  @primary_key false
  schema "roles_resources" do
    belongs_to :role, Yggdrasil.Role
    belongs_to :resource, Yggdrasil.Resource
    belongs_to :permission, Yggdrasil.Permission

    timestamps
  end
end
