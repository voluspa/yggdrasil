defmodule Yggdrasil.Repo.Migrations.CreateRoleResource do
  use Ecto.Migration

  def change do
    create table(:roles_resources, primary_key: false) do
      add :role_id, references(:roles, on_delete: :nothing)
      add :resource, references(:resources, on_delete: :nothing, column: :name, type: :string)
      add :permission, references(:permissions, on_delete: :nothing, column: :name, type: :string)

      timestamps
    end
    create index(:roles_resources, [:role_id])
    create unique_index(:roles_resources, [:role_id, :resource, :permission])

  end
end
