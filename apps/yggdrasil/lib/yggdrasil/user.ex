defmodule Yggdrasil.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2] # dislike this
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  require Logger

  schema "users" do
    field :username, :string
    field :hash, :string
    field :password, :string, virtual: true # not part of table
    field :password_confirmation, :string, virtual: true # not part of table
    belongs_to :role, Yggdrasil.Role

    timestamps
  end

  @doc """
  create_changeset should be used when creating a new user it ensures
  all the fields needed are there and valid and generates a password
  """
  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(username password password_confirmation), ~w())
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
    |> validate_length(:password, min: 4)
    |> validate_length(:password_confirmation, min: 4)
    |> validate_confirmation(:password)
    |> default_role
    |> hash_password
  end

  def with_role(query) do
    from q in query,
    preload: [
      role: [
        role_resources: [
          :resource,
          role_resource_permissions: [:permission]
        ]
      ]
    ]
  end

  @doc """
  adds password at end of chain protects the hashpwsalt from seeing a nil value
  in the case of missing password field.
  """
  def hash_password(changeset = %{:valid? => false}) do
    changeset
  end

  def hash_password(changeset = %{:valid? => true}) do
    changeset
      |> put_change(:hash, hashpwsalt(changeset.params["password"]))
  end

  def default_role(changeset = %{:valid? => false}) do
    changeset
  end

  def default_role(changeset = %{:valid? => true}) do
    # short term, if I don't put it here I will break
    # all the tests that require a user and that's a lot
    role = Yggdrasil.Repo.one! from r in Yggdrasil.Role,
                               where: r.name == "player",
                               select: r
    changeset
      |> put_change(:role_id, role.id)
  end
end
