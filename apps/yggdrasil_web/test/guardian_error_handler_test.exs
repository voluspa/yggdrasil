defmodule YggdrasilWeb.GuardianErrorHandlerTest do
  use YggdrasilWeb.ConnCase

  alias YggdrasilWeb.GuardianErrorHandler

  test "calling unauthenticated sends a 401", %{conn: conn} do
    conn = GuardianErrorHandler.unauthenticated(conn, [])

    response(conn, 401)
  end

  test "calling unauthorized sends a 401", %{conn: conn} do
    conn = GuardianErrorHandler.unauthorized(conn, [])

    response(conn, 401)
  end
end
