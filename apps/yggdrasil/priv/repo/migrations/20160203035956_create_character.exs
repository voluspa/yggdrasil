defmodule Yggdrasil.Repo.Migrations.CreateCharacter do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string
      add :ext_id, :id
      add :game_id, references(:games, on_delete: :nothing)

      timestamps
    end
    create index(:characters, [:ext_id])
    create index(:characters, [:game_id])
    create unique_index(:characters, [:name, :game_id])

  end
end
