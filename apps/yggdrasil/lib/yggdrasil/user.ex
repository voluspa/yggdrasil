defmodule Yggdrasil.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Yggdrasil.{Repo, User, Role, UserRole}

  @default_role "player"

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
          :ok        <- assign_role(user, "player"),
     do: {:ok, user}
  end

  def assign_role(user, role_name) do
    role = Repo.one!(from r in Role, where: r.name == ^role_name, select: r)

    case Repo.insert(%UserRole{ user_id: user.id, role_id: role.id }) do
      {:ok, _role} -> :ok
      error        -> error
    end
  end

  @doc ~S"""
  Checks the list of resource/permissions pair given against what the user
  has been granted and returns true if and only if all permissions supplied
  have been granted for the user.

  ## roles
  A user can have one or more roles with each role having a set of resources
  and a set of resources and those resources having a set of permissions. Roles
  are not checked directly and only serve as a grouping mechanism for resources.

  Since the user can have multiple roles, the permission set checked for a given
  resource is the unique set across all the roles for that resource.

  So if the user has `Role1` and `Role2` defined as follows:

  * Role1
    * foo
      * :read
      * :write
  * Role2
    * foo
      * :read
      * :all

  The set of permissions checked for foo will be `[:read, :write, :all]`

  ## Examples
      # checking a single resource
      User.is_granted? user, foo: [:read]

      # checking multiple resources is allowed as well
      User.is_granted? user, foo: [:read], bar: [:read, :write]
  """
  def is_granted?(user, res_perms) do
    # ensure users roles and the rest are loaded
    # this does nothing if they are.
    user = preload_roles(user)

    results = Enum.map res_perms, fn {res, perms} ->
      res_perm_set = user.user_roles
      |> Enum.flat_map(fn ur -> ur.role.role_resources end)
      |> Enum.filter(fn r -> r.resource.name == Atom.to_string(res) end)
      |> Enum.map(fn r -> r.permission.name end)
      |> MapSet.new

      # turn perm atoms into strings
      perm_set = perms
      |> Enum.map(fn p -> Atom.to_string(p) end)
      |> MapSet.new

      # subset returns true if the one being tested
      # as a subset is empty
      with true <- MapSet.size(res_perm_set) != 0,
           true <- MapSet.size(perm_set) != 0,
       do: MapSet.subset? perm_set, res_perm_set
    end

    # all? defaults to checking for truthy values
    Enum.all? results
  end

  @doc """
  Query that preloads the all the user_roles for a user inlcuding
  all the subsequent associations.
  """
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

  @doc """
  Preloads the all the user_roles for a user that has already beend
  fetched. This will loadd all subsequent roles like `with_roles` does
  """
  def preload_roles(user) do
    query = from ur in UserRole,
    preload: [
      role: [
        role_resources: [
          :resource,
          :permission
        ]
      ]
    ]

    Repo.preload(user, user_roles: query)
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
