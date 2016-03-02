defmodule YggdrasilWeb.EnsurePermission do
  @moduledoc ~S"""
  ## Overview
  This plug takes in a connection and set of permission and ensures that all
  permissions provided are present for the user on the connection.

    import Yggdrasil.EnsurePermission

    plug EnsurePermission, [foo: [:read]] when action in [:index]

  ## Roles and Permissions 
  The user's permissions are dictated by their role. Each role has a set
  resources and each resource has a set of permissions. With this scheme
  the res_perms passed in are in the form of:

  [resource: [perm_set], resource: [perm_set]]

  for as many resources and permissions that are needed. Then each resource is
  processed in the list looking up the resource on the role, and then validating
  that the set of perms passed in are contained in the set for the given resource
  on the role.

  If and only if all resources provided are found, and all permissions for each
  resource are in present for that resource on the user's given role will this
  plug process the request, otherwise it will send a 401 and stop processing
  """

  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, res_perms) do
    if all?(conn, res_perms) do
      conn
    else
      conn
      |> send_resp(:unauthroized, "")
      |> halt
    end
  end

  def all?(conn, res_perms) do
    user = Guardian.Plug.current_resource(conn)
    resources = user.role.role_resources

    results = Enum.map res_perms, fn {res, perms} ->
      resource = Enum.find resources, fn r ->
        r.resource.name == Atom.to_string(res)
      end

      if resource do
        # turn perm atoms into strings
        perms = Enum.map perms, fn p -> Atom.to_string(p) end

        # reduce to a names only to compare
        r_perms = Enum.map resource.role_resource_permissions, fn rp ->
          rp.permission.name
        end

        perm_set = MapSet.new perms
        res_perm_set = MapSet.new r_perms

        # is perm_set a sub set of res_perm_set?
        MapSet.subset? perm_set, res_perm_set
      else
        Logger.warning fn -> "#{res} is not a resource on #{user.role.name}" end
        false
      end
    end

    # all? defaults to checking for truthy values
    Enum.all? results
  end
end
