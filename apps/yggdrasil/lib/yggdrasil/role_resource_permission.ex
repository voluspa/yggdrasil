defmodule Yggdrasil.RoleResourcePermission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles_resources_permissions" do
    belongs_to :role_resource, Yggdrasil.RoleResource
    belongs_to :permission, Yggdrasil.Permission

    timestamps
  end
end
