defmodule Yggdrasil.Repo.Migrations.PopulateRoles do
  use Ecto.Migration

  def up do
    execute """
		with rpms as (
			select 
				rs.id as res_id, 
    		rs.name as res_name,
				ps.id as perm_id,
				ps.name as perm_name
			from resources rs
    		cross join permissions ps
		),
		rol as (
			insert into roles(name, inserted_at, updated_at) values
			('player', now(), now()),
			('admin', now(), now())
			returning *
		),
		rol_res as (
			insert into roles_resources(role_id, resource_id, inserted_at, updated_at)
			select rol.id, resources.id, now(), now()
			from rol
				cross join resources
			returning *
		)
		insert into roles_resources_permissions(role_resource_id, permission_id, inserted_at, updated_at)
		select rol_res.id, rpms.perm_id, now(), now()
		from rol_res
			join rol on rol.id = rol_res.role_id
			join rpms on rpms.res_id = rol_res.resource_id
		where 
			-- don't want admin permission for player as well as for the game resource
			-- the player doesn't need write
			not (rol.name = 'player' and rpms.perm_name = 'admin')
			and not (rol.name = 'player' and rpms.perm_name = 'write' and rpms.res_name = 'game');
    """
  end
end
