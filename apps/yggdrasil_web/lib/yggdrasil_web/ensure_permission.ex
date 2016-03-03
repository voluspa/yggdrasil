defmodule YggdrasilWeb.EnsurePermission do
  @moduledoc ~S"""
  ## Overview
  This plug checks to ensure all permissions provided have been granted for
  the user on the connection. If all permissions have been granted then the 
  plug will allow the request to proceed otherwise it will send a 401 to the
  client and halt the connection.

  ## Roles
  A user can have one or more roles with each role having a set of resources
  and a set of resources and those resources having a set of permissions. Roles
  are not checked directly and only serve as a grouping mechanism for resources.

  This plug only deals with resources and the permissions associated with them
  so in the examples below you will that keyword lists are used where the key is
  the resource desired and the value is the set of permissions to check.

  Since the user can have multiple roles, the permission set checked for a given
  resource is the unique set across all the roles for that resource.

  So if the user has Role1 and Role2 defined as follows:

    * Role1
      * foo
        * :read
        * :write
    * Role2
      * foo
        * :read
        * :all

  The set of permissions checked for foo will be [:read, :write, :all]

  ## Examples
    import Yggdrasil.EnsurePermission

    # checking a single resource
    plug EnsurePermission, [foo: [:read]]

    # checking multiple resources is allowed as well
    plug EnsurePermission, [foo: [:read], bar: [:read, :write]]

    # being a plug it can also be used with guard to only restrict certain
    # actions with permissions. In the following example the :index action
    # will only be allowed if the foo resource has the :read permission
    plug EnsurePermission, [foo: [:read]] when action [:index]
  """

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, res_perms) do
    if all?(conn, res_perms) do
      conn
    else
      conn
      |> send_resp(:unauthorized, "")
      |> halt
    end
  end

  def all?(conn, res_perms) do
    user = Guardian.Plug.current_resource(conn)

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

      if MapSet.size(res_perm_set) == 0 do
        false
      else
        MapSet.subset? perm_set, res_perm_set
      end
    end

    # all? defaults to checking for truthy values
    Enum.all? results
  end
end
