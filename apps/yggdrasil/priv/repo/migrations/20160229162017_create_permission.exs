defmodule Yggdrasil.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add :name, :string, primary_key: true

      timestamps
    end

  end
end
