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
require Logger

alias Yggdrasil.{Repo, Resource, Permission, Role, RolePermission}

perms = ["read", "write", "all"]
res = ["character", "game"]

Repo.transaction fn ->
  Enum.each perms, fn p ->
    if Repo.get(Permission, p) == nil do
      Repo.insert! %Permission{name: p}
    else
      Logger.warn fn -> "found permission #{p} skipping insert" end
    end
  end

  Enum.each res, fn r ->
    if Repo.get(Resource, r) == nil do
      Repo.insert! %Resource{name: r}
    else
      Logger.warn fn -> "found resource #{r} skipping insert" end
    end
  end

  # NOTE: only checks to see if the role exists
  # if so skips it, it doesn't try to be fancy
  # if a role is found also ensure permissions
  # are indeed there.

  # player role ---
  player_role = Repo.get_by(Role, name: "player")

  if player_role == nil do
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
  else
    Logger.warn fn -> "found role #{player_role.name} skipping insert" end
  end

  # admin role ---
  admin_role = Repo.get_by(Role, name: "admin")

  if admin_role == nil do
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
  else
    Logger.warn fn -> "found role #{admin_role.name} skipping insert" end
  end
end
