defmodule Yggdrasil.UserRoleTest do
  use ExUnit.Case, async: false

  alias Yggdrasil.{Repo, User, Role, UserRole, RolePermission, Resource, Permission}

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
    }
  ]

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Yggdrasil.Repo, [])
    end

    :ok
  end

  setup _ctx do
    Enum.each @test_perms, fn p ->
      Repo.insert! %Permission{name: Atom.to_string(p)}
    end

    Enum.each @test_resources, fn r ->
      Repo.insert! %Resource{name: Atom.to_string(r)}
    end

    roles = Enum.map @test_roles, fn tr ->
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

      role
    end

    user = %User{}
    |> User.create_changeset(@user)
    |> Repo.insert!()

    [role] = roles
    {:ok, %{user: user, role: role}}
  end

  test "changeset/2 with invalid user and valid role returns an error", ctx do
    result = %UserRole{}
    |> UserRole.changeset(%{user_id: -12, role_id: ctx.role.id})
    |> Repo.insert

    assert {:error, _} = result

    {:error, changeset} = result
    assert {:user, "does not exist"} in changeset.errors
  end

  test "changeset/2 with invalid role and valid user returns an error", ctx do
    result = %UserRole{}
    |> UserRole.changeset(%{user_id: ctx.user.id, role_id: -12})
    |> Repo.insert

    assert {:error, _} = result

    {:error, changeset} = result
    assert {:role, "does not exist"} in changeset.errors
  end

  test "changeset/2 with valid user and role", ctx do
    result = %UserRole{}
    |> UserRole.changeset(%{user_id: ctx.user.id, role_id: ctx.role.id})
    |> Repo.insert

    assert {:ok, _} = result
  end
end
