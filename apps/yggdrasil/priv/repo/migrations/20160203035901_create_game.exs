defmodule Yggdrasil.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :description, :string

      timestamps
    end
    create unique_index(:games, [:name])

  end
end
