defmodule Yggdrasil.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "users_roles" do
    belongs_to :user, Yggdrasil.User
    belongs_to :role, Yggdrasil.Role

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:user_id, :role_id], [])
    |> unique_constraint(:user_id, name: :users_roles_user_id_role_id_index)
    |> assoc_constraint(:user)
    |> assoc_constraint(:role)
  end
end
