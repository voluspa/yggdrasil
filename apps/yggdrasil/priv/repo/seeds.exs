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
alias Yggdrasil.{Repo, Resource, Permission, Role, RoleResource}

Repo.transaction fn ->
  perms = Enum.map ["read", "write", "all"], fn p ->
    Repo.insert! %Permission{name: p}
  end

  res = Enum.map ["character", "game"], fn r ->
    Repo.insert! %Resource{name: r}
  end

  # player role ---
  player_role = Repo.insert! %Role{name: "player"}

  player_perms = Enum.filter perms, fn p -> p.name != "all" end

  Enum.each res, fn r ->
    permissions = if r.name == "game" do
      Enum.filter player_perms, fn p -> p.name != "write" end
    else
      player_perms
    end

    Enum.each permissions, fn p ->
      Repo.insert! %RoleResource{
        role_id: player_role.id,
        resource_id: r.id,
        permission_id: p.id
      }
    end
  end

  # admin role ---
  admin_role = Repo.insert! %Role{name: "admin"}

  Enum.each res, fn r ->
    Enum.each perms, fn p ->
      Repo.insert! %RoleResource{
        role_id: admin_role.id,
        resource_id: r.id,
        permission_id: p.id
      }
    end
  end
end
