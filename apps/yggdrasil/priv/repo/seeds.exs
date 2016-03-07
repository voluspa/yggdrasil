# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Yggdrasil.Repo.insert!(%Yggdrasil.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Yggdrasil.{Repo, Resource, Permission, Role, RolePermission}

perms = ["read", "write", "all"]
res = ["character", "game"]

Repo.transaction fn ->
  Enum.each perms, fn p ->
    Repo.insert! %Permission{name: p}
  end

  Enum.each res, fn r ->
    Repo.insert! %Resource{name: r}
  end

  # player role ---
  player_role = Repo.insert! %Role{name: "player"}

  player_perms = Enum.filter perms, fn p -> p != "all" end

  Enum.each res, fn r ->
    permissions = if r == "game" do
      Enum.filter player_perms, fn p -> p != "write" end
    else
      player_perms
    end

    Enum.each permissions, fn p ->
      Repo.insert! %RolePermission{
        role_id: player_role.id,
        resource: r,
        permission: p
      }
    end
  end

  # admin role ---
  admin_role = Repo.insert! %Role{name: "admin"}

  Enum.each res, fn r ->
    Enum.each perms, fn p ->
      Repo.insert! %RolePermission{
        role_id: admin_role.id,
        resource: r,
        permission: p
      }
    end
  end
end
