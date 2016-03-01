defmodule Yggdrasil.Repo.Migrations.PopulateResources do
  use Ecto.Migration

  def up do
    execute """
    insert into resources(name, inserted_at, updated_at) values
    ('character', now(), now()),
    ('game', now(), now())
    """
  end
end
