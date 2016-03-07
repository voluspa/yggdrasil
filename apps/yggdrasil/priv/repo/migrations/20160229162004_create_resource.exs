defmodule Yggdrasil.Repo.Migrations.CreateResource do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add :name, :string, primary_key: true

      timestamps
    end
    create unique_index(:resources, [:name])

  end
end
