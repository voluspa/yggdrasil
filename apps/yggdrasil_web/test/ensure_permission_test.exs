defmodule YggdrasilWeb.EnsurePermissionTest do
  use YggdrasilWeb.ConnCase

  alias YggdrasilWeb.EnsurePermission
  alias Yggdrasil.{Repo, User, Role, RolePermission, Resource, Permission}

  @user %{username: "tester",
          password: "password",
          password_confirmation: "password"}

  @test_perms [:foo_perm, :bar_perm, :baz_perm]
  @test_resources [:foo_res, :bar_res, :baz_res]
  @test_roles [
    %{
      name: :foo_role,
      resources: [
        %{
          name: :foo_res,
          perms: [:foo_perm, :bar_perm]
        },
        %{
          name: :bar_res,
          perms: [:bar_perm, :baz_perm]
        }
      ]
    },
    %{
      name: :bar_role,
      resources: [
        %{
          name: :foo_res,
          perms: [:baz_perm]
        },
        %{
          name: :bar_res,
          perms: [:foo_perm, :baz_perm]
        },
        %{
          name: :baz_res,
          perms: [:foo_perm, :bar_perm, :baz_perm]
        }
      ]
    }
  ]

  setup %{conn: conn} do
    Enum.each @test_perms, fn p ->
      Repo.insert! %Permission{name: Atom.to_string(p)}
    end

    Enum.each @test_resources, fn r ->
      Repo.insert! %Resource{name: Atom.to_string(r)}
    end

    Enum.each @test_roles, fn tr ->
      role = Repo.insert! %Role{name: Atom.to_string(tr.name)}

      Enum.each tr.resources, fn trs ->
        Enum.each trs.perms, fn trpm ->
          Repo.insert! %RolePermission{
            role_id: role.id,
            resource: Atom.to_string(trs.name),
            permission: Atom.to_string(trpm)
          }
        end
      end
    end

    user = %User{}
    |> User.create_changeset(@user)
    |> Repo.insert!()

    Enum.each @test_roles, fn r ->
      User.assign_role(user, Atom.to_string(r.name))
    end

    {:ok, token, _claims} = Guardian.encode_and_sign user, :token

    # setup connection, this is boiler plate
    conn = conn
    |> put_req_header("authorization", token)
    |> bypass_through(YggdrasilWeb.Router, [:guardian])
    |> get("/") # bypass_through skips router matching, so this is fine

    {:ok, %{conn: conn, user: %{model: user, token: token}}}
  end

  test "EnsurePermission.call/2 doesn't halt connection with correct permissions", ctx do
    conn = ctx.conn
    |> EnsurePermission.call(foo_res: [:foo_perm])
    |> send_resp(:no_content, "")

    refute conn.halted
    assert response(conn, :no_content)
  end

  test "EnsurePermission.call/2 halts connection without correct permissions and issues a 401", ctx do
    conn = ctx.conn
    |> EnsurePermission.call(foo_res: [:foo_perm, :bar_bar])

    assert conn.halted
    assert response(conn, :unauthorized)
  end
end
