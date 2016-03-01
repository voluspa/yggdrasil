defmodule Yggdrasil.Repo.Migrations.PopulatePermissions do
  use Ecto.Migration

  def up do
    execute """
    insert into permissions(name, inserted_at, updated_at) values
    ('read', now(), now()),
    ('write', now(), now()),
    ('admin', now(), now())
    """
  end
end
