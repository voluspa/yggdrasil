defmodule Yggdrasil.Repo.Migrations.CreateRoleResource do
  use Ecto.Migration

  def change do
    create table(:roles_resources) do
      add :role_id, references(:roles, on_delete: :nothing)
      add :resource_id, references(:resources, on_delete: :nothing)
      add :permission_id, references(:permissions, on_delete: :nothing)

      timestamps
    end
    create index(:roles_resources, [:role_id])
    create index(:roles_resources, [:resource_id])
    create index(:roles_resources, [:permission_id])

  end
end
