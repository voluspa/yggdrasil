defmodule Yggdrasil.Repo.Migrations.CreateRoleResourcePermission do
  use Ecto.Migration

  def change do
    create table(:roles_resources_permissions) do
      add :role_resource_id, references(:roles_resources, on_delete: :nothing)
      add :permission_id, references(:permissions, on_delete: :nothing)

      timestamps
    end
    create index(:roles_resources_permissions, [:role_resource_id])
    # Don't think this is needed, I would imagine most if not all
    # queries would come through the role_resource_id for a record
    create index(:roles_resources_permissions, [:permission_id])

  end
end
