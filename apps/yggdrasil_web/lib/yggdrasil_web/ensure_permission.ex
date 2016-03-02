defmodule YggdrasilWeb.EnsurePermission do
  import Plug.Conn

  def init(opts) do
    opts
  end

  @doc """
  res_perms contains a keyword list of perms where the key is the resource

  typical use would be

  foo: [:read] 

  for example where it asks if foo resource has the :read permission
  and of course can be expanded to as many permissions as needed like

  foo: [:read, :write]

  however it does support multiple resources so the following is valid

  [foo: [:read], bar: [:read, :write]]

  each resoure will be checked to ensure all the permissions listed are present
  for the user in the connection and will return true if and only if all permissions
  listed for each resources are found otherwise it will return false.

  this applies to both call and check_permissions
  """
  def call(conn, res_perms) do
    if valid?(conn, res_perms) do
      conn
    else
      send_resp(conn, :unauthroized, "")
    end
  end

  def check_permissions(conn, res_perms) do
    valid?(conn, res_perms)
  end

  defp valid?(conn, res_perms) do
    user = Guardian.Plug.current_resource(conn)
    resources = user.role.role_resources

    results = Enum.map res_perms, fn {res, perms} ->
      resource = Enum.find resources, fn r -> r.resource.name == Atom.to_string(res) end

      # turn perm atoms into strings
      perms = Enum.map perms, fn p -> Atom.to_string(p) end

      # reduce to a names only to compare
      r_perms = Enum.map resource.role_resource_permissions, fn rp ->
        rp.permission.name
      end

      perm_set = MapSet.new perms
      res_perm_set = MapSet.new r_perms

      # subset? checks to see if the first arg is a subset of the second arg
      # so this reads is perm_set a sup set of res_perm_set if true then
      # the user has the set of perms passed in.

      # this also covers if the two sets match as the first is stil considered a
      # "subset" of the sceond even when they are equal.
      MapSet.subset? perm_set, res_perm_set
    end

    # all? defaults to checking for truthy values
    Enum.all? results
  end
end
