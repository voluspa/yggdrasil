defmodule Yggdrasil.UserRole do
  use Ecto.Schema

  schema "users_roles" do
    belongs_to :user, Yggdrasil.User
    belongs_to :role, Yggdrasil.Role

    timestamps
  end
end
