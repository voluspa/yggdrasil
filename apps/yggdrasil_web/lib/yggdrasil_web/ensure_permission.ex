defmodule YggdrasilWeb.EnsurePermission do
  @moduledoc ~S"""
  ## Overview
  This plug checks to ensure all permissions provided have been granted for
  the user on the connection. If all permissions have been granted then the 
  plug will allow the request to proceed otherwise it will send a 401 to the
  client and halt the connection.

  Please check the docs for `Yggdrasil.User.is_granted?/2`, which is the internal
  call that checks the user's permissions. More details can be found there.

  ## Examples
      # checking a single resource
      plug EnsurePermission, [foo: [:read]]

      # checking multiple resources is allowed as well
      plug EnsurePermission, [foo: [:read], bar: [:read, :write]]

  being a plug it can also be used with guard to only restrict certain
  actions with permissions. In the following example the :index action
  will only be allowed if the foo resource has the :read permission
      plug EnsurePermission, [foo: [:read]] when action [:index]
  """

  import Plug.Conn

  alias Yggdrasil.User

  def init(opts) do
    opts
  end

  def call(conn, res_perms) do
    user = Guardian.Plug.current_resource(conn)
    if User.is_granted!(user, res_perms) do
      conn
    else
      conn
      |> send_resp(:unauthorized, "")
      |> halt
    end
  end
end
