defmodule Yggdrasil.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Yggdrasil.{Repo, User, Role, UserRole}

  schema "users" do
    field :username, :string
    field :hash, :string
    field :password, :string, virtual: true # not part of table
    field :password_confirmation, :string, virtual: true # not part of table

    has_many :user_roles, Yggdrasil.UserRole

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
    |> hash_password
  end

  @doc """
  Creates the user and assigns the default roles of "player"
  """
  def create_with_default_role(attributes) do
    changeset = User.create_changeset(%User{}, attributes)

    with {:ok, user} <- Repo.insert(changeset),
          :ok        <- add_default_role(user),
     do: {:ok, user}
  end

  defp add_default_role(user) do
    default = Repo.one!(from r in Role, where: r.name == "player", select: r)

    case Repo.insert(%UserRole{ user_id: user.id, role_id: default.id }) do
      {:ok, _role} -> :ok
      error        -> error
    end
  end

  def with_roles(query) do
    from q in query,
    preload: [
      user_roles: [
        role: [
          role_resources: [
            :resource,
            :permission
          ]
        ]
      ]
    ]
  end

  # adds password at end of chain protects the hashpwsalt from seeing a nil value
  # in the case of missing password field.
  defp hash_password(changeset = %{:valid? => false}) do
    changeset
  end

  defp hash_password(changeset = %{:valid? => true}) do
    changeset
      |> put_change(:hash, hashpwsalt(changeset.params["password"]))
  end
end
