defmodule Yggdrasil.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  require Logger

  alias Yggdrasil.{Repo, User, Role, UserRole}

  @default_role "player"

  schema "users" do
    field :username, :string
    field :hash, :string
    field :password, :string, virtual: true # not part of table
    field :password_confirmation, :string, virtual: true # not part of table
    field :permissions, :any, default: [], virtual: true # :any skips type checking

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
    role = Repo.get_by!(Role, name: role_name)

    user_role = UserRole.changeset(%UserRole{},
                                   %{user_id: user.id, role_id: role.id})
    case Repo.insert(user_role) do
      {:ok, _role} -> :ok
      error        -> error
    end
  end

  def load_permissions(user) do
    query = from ur in UserRole,
            where: ur.user_id ==  ^user.id,
            preload: [role: [:role_permissions]]

    permissions = query
    |> Repo.all()
    |> Enum.flat_map(fn ur -> ur.role.role_permissions end)
    |> Enum.group_by(fn rp -> rp.resource end)
    |> Enum.map(fn {r, rps} -> {String.to_atom(r), Enum.map(rps, fn rp -> String.to_atom(rp.permission) end)} end)
    |> Enum.into(%{})

    %{ user | permissions: permissions}
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

  def is_granted?(_user, []),  do: raise_error "resource keyword list is empty"
  def is_granted?(_user, nil), do: raise_error "resource keyword list is nil"
  def is_granted?(user, res_perms) do
    res_perms
    |> Enum.map(fn {res, perms} -> {res, user.permissions[res], perms} end)
    |> Enum.map(&has_permissions/1)
    |> Enum.all?
  end

  defp has_permissions({_res, nil, _requried}), do: false
  defp has_permissions({res, _given, nil}),     do: raise_error "required permission list is nil for #{res}"
  defp has_permissions({res, [], _required}),   do: raise_error "given permission list is empty for #{res}"
  defp has_permissions({res, _given, []}),      do: raise_error "required permission list is empty for #{res}"
  defp has_permissions({_res, given, required}) do
    given = MapSet.new given
    required = MapSet.new required

    MapSet.subset?(required, given)
  end

  defp raise_error(msg) do
    Logger.error msg
    raise ArgumentError, message: msg
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
