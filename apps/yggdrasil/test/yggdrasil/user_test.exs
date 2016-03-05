defmodule Yggdrasil.UserTest do
  use ExUnit.Case, async: false
  import Ecto.Query, only: [from: 1, from: 2]

  alias Yggdrasil.{Repo, User, Role, RoleResource, Resource, Permission}
  alias Comeonin.Bcrypt

  @min_len 4
  @password "password"
  @short_password String.slice(@password, 1..(@min_len - 1))

  @valid_attrs %{username: "tester", password: @password, password_confirmation: @password }

  @valid_attrs_upcase_user    Map.update!(@valid_attrs, :username, &String.upcase/1)
  @hash_included              Map.put(@valid_attrs, :hash, "invalid_password")
  @missing_username           Map.drop(@valid_attrs, [:username])
  @missing_password           Map.drop(@valid_attrs, [:password])
  @missing_password_conf      Map.drop(@valid_attrs, [:password_confirmation])
  @password_mismatch          %{@valid_attrs | :password => "not password"}
  @password_bad_len           %{@valid_attrs | :password => @short_password}
  @password_conf_bad_len      %{@valid_attrs | :password => @short_password,
                                               :password_confirmation => @short_password}

  @blank_msg "can't be blank"
  @doesntmatch_msg "does not match confirmation"
  @unique_msg "has already been taken"
  @invalid_length_msg "should be at least %{count} character(s)"

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

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Yggdrasil.Repo, [])
    end

    :ok
  end

  # -- helpers

  defp valid_hash(hash) do
    Bcrypt.checkpw(@password, hash)
  end

  defp hash_missing?(changeset) do
    !Map.has_key?(changeset.changes, :hash)
  end

  defp insert_test_roles do
    perms = Enum.map @test_perms, fn p ->
      Repo.insert! %Permission{name: Atom.to_string(p)}
    end

    res = Enum.map @test_resources, fn r ->
      Repo.insert! %Resource{name: Atom.to_string(r)}
    end

    Enum.map @test_roles, fn tr ->
      role = Repo.insert! %Role{name: Atom.to_string(tr.name)}

      Enum.each tr.resources, fn trs ->
        resource = Enum.find res, fn rs -> rs.name == Atom.to_string(trs.name) end

        Enum.each trs.perms, fn trpm ->
          permission = Enum.find perms, fn pm -> 
            pm.name == Atom.to_string(trpm)
          end

          Repo.insert! %RoleResource{
            role_id: role.id,
            resource_id: resource.id,
            permission_id: permission.id
          }
        end
      end

      role
    end
  end

  defp user_perms_for_roles(roles) do
    insert_test_roles()

    user = %User{}
    |> User.create_changeset(@valid_attrs)
    |> Repo.insert!()

    Enum.each roles, fn r ->
      :ok = User.assign_role(user, Atom.to_string(r.name))
    end

    res_perm_list = roles
    |> Enum.flat_map(fn r -> r.resources end)
    |> Enum.group_by(fn res -> res.name end)
    |> Enum.map(fn {res_name, res} -> 
        {res_name, Enum.flat_map(res, fn res -> res.perms end)}
       end)

    res_uniq_perm_list = Enum.map res_perm_list, fn {res, perms} ->
      {res, Enum.uniq(perms)}
    end

    {user, res_uniq_perm_list, res_perm_list}
  end

  defp produce_resoure_perms_combos(res_perms) do
    # unique combinations per resource
    # [[foo: [:foo_p, :bar_p], foo: [:bar_p], foo: [foo_p]], [bar: [:foo_p, :bar_p], bar: [:foo_p], etc...]]
    res_perm_combo = Enum.map res_perms, fn {k, v} ->
      Enum.flat_map(1..Enum.count(v), &(Combination.combine(v, &1)))
      |> Enum.map(fn combos -> {k, combos} end)
    end

    # taks the res_perm_combo and produces a list of resource/perm list combos
    # so the size of list combos is the number of resources and why the count of 
    # res_perm_list is taken. In order to produce list of combos the combinations where
    # a resoure appears twice or for the whole combo list needs to be filtered out. 
    # so this produces 
    # [[foo: [:foo_p, :bar_p], bar: [:foo_p]], [foo: [:foo_p, :bar_p], bar: [:foo_p, :bar_p]]] etc..
    uniq_res_perm_combos = res_perm_combo
    |> List.flatten 
    |> Combination.combine(Enum.count(res_perms))
    |> Enum.filter(fn combo -> combo == Enum.uniq_by(combo, fn {k, _} -> k end) end)

    {res_perm_combo, uniq_res_perm_combos}
  end

  defp ensure_roles_are_loaded(user) do
    all_roles_loaded = fn ur ->
      Ecto.assoc_loaded?(ur.role)
    end

    all_role_resources_loaded = fn ur ->
      Ecto.assoc_loaded?(ur.role.role_resources)
    end

    all_resources_loaded = fn ur ->
      Enum.map ur.role.role_resources, fn rr ->
        Ecto.assoc_loaded?(rr.resource)
      end
    end

    all_permissions_loaded = fn ur ->
      Enum.map ur.role.role_resources, fn rr ->
        Ecto.assoc_loaded?(rr.permission)
      end
    end

    with true <- Ecto.assoc_loaded?(user.user_roles),
         true <- Enum.all?(Enum.map(user.user_roles, all_roles_loaded)),
         true <- Enum.all?(Enum.map(user.user_roles, all_role_resources_loaded)),
         true <- Enum.all?(Enum.flat_map(user.user_roles, all_resources_loaded)),
         true <- Enum.all?(Enum.flat_map(user.user_roles, all_permissions_loaded)),
     do: true
  end

  # -- tests

  test "create_changeset with valid attributes" do
    changeset = User.create_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "create_changeset with missing username" do
    changeset = User.create_changeset(%User{}, @missing_username)

    assert changeset.errors[:username] == @blank_msg
    refute changeset.valid?
  end

  test "create_changeset with missing password" do
    changeset = User.create_changeset(%User{}, @missing_password)

    assert changeset.errors[:password] == @blank_msg
    refute changeset.valid?
  end

  test "create_changeset with missing password_confirmation" do
    changeset = User.create_changeset(%User{}, @missing_password_conf)

    assert changeset.errors[:password_confirmation] == @blank_msg
    refute changeset.valid?
  end

  test "create_changeset with password mismatch" do
    changeset = User.create_changeset(%User{}, @password_mismatch)

    assert changeset.errors[:password_confirmation] == @doesntmatch_msg
    refute changeset.valid?
  end

  test "create_changeset with password less than min fails" do
    changeset = User.create_changeset(%User{}, @password_bad_len)

    assert changeset.errors[:password] == {@invalid_length_msg, [count: @min_len]}
    refute changeset.valid?
  end

  test "create_changeset with password_confirmation less than min fails" do
    changeset = User.create_changeset(%User{}, @password_conf_bad_len)

    assert changeset.errors[:password_confirmation] == {@invalid_length_msg, [count: @min_len]}
    refute changeset.valid?
  end

  test "create_changeset unique username constraint" do
    # insert the user once
    user_changeset = User.create_changeset(%User{}, @valid_attrs)
    {:ok, _user} = Repo.insert(user_changeset)

    # try again to invoke unique constraint
    {:error, changeset} = Repo.insert(user_changeset)
    assert changeset.errors[:username] == @unique_msg
    refute changeset.valid?
  end

  test "create_changeset downcases username" do
    user = User.create_changeset(%User{}, @valid_attrs_upcase_user)

    assert user.changes.username == "tester"
  end

  test "create_changet generates hash if valid" do
    changeset = User.create_changeset(%User{}, @valid_attrs)

    assert Map.has_key?(changeset.changes, :hash)

    hash = changeset.changes.hash
    assert valid_hash(hash)
  end

  test "create_changet doesn't generates hash if username missing" do
    changeset = User.create_changeset(%User{}, @valid_attrs)

    assert Map.has_key?(changeset.changes, :hash)

    hash = changeset.changes.hash
    assert valid_hash(hash)
  end

  test "create_changeset with missing username doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @missing_username)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset with missing password doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @missing_password)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset with missing password_confirmation doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @missing_password_conf)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset with password mismatch doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @password_mismatch)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset with password less than min doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @password_bad_len)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset with password_confirmation less than min doesn't generate hash" do
    changeset = User.create_changeset(%User{}, @password_conf_bad_len)

    refute changeset.valid?
    assert hash_missing?(changeset)
  end

  test "create_changeset that is valid with hash passed in ignores hash" do
    changeset = User.create_changeset(%User{}, @hash_included)

    assert changeset.valid?
    refute changeset.changes.hash == @hash_included.hash
  end

  # Don't think we need to test this but just incase, fairly certain only
  # fields included in the changes map are actually commited
  test "create_changeset that is valid with hash in model is ignored" do
    changeset = User.create_changeset(%User{:hash => "invalid_password"}, @valid_attrs)

    assert changeset.valid?
    refute changeset.changes.hash == @hash_included.hash

    {:ok, user} = Repo.insert(changeset)
    refute user.password == "invalid_password"
  end

  test "create_changeset that is invalid with hash passed no hash is present" do
    changeset = User.create_changeset(%User{}, @missing_username)

    refute changeset.valid?
    refute Map.has_key?(changeset.changes, :hash)
  end

  test "is_granted?/2 returns true with all granted resource/perms" do
    {user, res_uniq_perm_list, _} = user_perms_for_roles(@test_roles)

    assert User.is_granted? user, res_uniq_perm_list
  end

  test "is_granted?/2 returns true for any one resources's granted permission set" do
    {user, res_uniq_perm_list, _} = user_perms_for_roles(@test_roles)

    Enum.each res_uniq_perm_list, fn res_perm ->
      assert User.is_granted? user, [res_perm]
    end
  end

  test "is_granted?/2 returns true any combination of granted permissions" do
    {user, res_uniq_perm_list, _} = user_perms_for_roles(@test_roles)

    {res_perm_combo, uniq_res_perm_combos} = produce_resoure_perms_combos(res_uniq_perm_list)

    # lets check each resource combo individually first
    Enum.each res_perm_combo, fn res_list ->
      Enum.each res_list, fn combo ->
        assert User.is_granted? user, [combo]
      end
    end

    # now lets check all the combos
    Enum.each uniq_res_perm_combos, fn combo ->
      assert User.is_granted? user, combo
    end
  end

  test "is_granted?/2 returns false for all combinations of non granted permissions" do
    {user, res_uniq_perm_list, _} = user_perms_for_roles(@test_roles)

    res_uniq_perm_list = Enum.map res_uniq_perm_list, fn {res, perms} ->
      perms = Enum.map perms, fn p -> 
        p = Atom.to_string(p)
        p = p <> "_false"
        String.to_atom(p)
      end

      {res, perms}
    end

    {res_perm_combo, uniq_res_perm_combos} = produce_resoure_perms_combos(res_uniq_perm_list)

    # lets check each resource combo individually first
    Enum.each res_perm_combo, fn res_list ->
      Enum.each res_list, fn combo ->
        refute User.is_granted? user, [combo]
      end
    end

    # now lets check all the combos
    Enum.each uniq_res_perm_combos, fn combo ->
      refute User.is_granted? user, combo
    end
  end

  test "create_with_default_role/1 creates user and assigns 'player' as the default role" do
    role = Repo.one!(from r in Role, where: r.name == "player", select: r)

    {:ok, user} = User.create_with_default_role(@valid_attrs) 
    user = Repo.preload(user, :user_roles)

    default_role = Enum.find user.user_roles, fn ur ->
      ur.role_id == role.id
    end

    assert default_role.role_id == role.id
  end

  test "assign_role/2 associates supplied role to user" do
    [role|_rest] = insert_test_roles

    user = %User{}
    |> User.create_changeset(@valid_attrs)
    |> Repo.insert!

    :ok = User.assign_role(user, role.name)

    user = Repo.preload(user, :user_roles)

    assigned_role = Enum.find user.user_roles, fn ur ->
      ur.role_id == role.id
    end
    assert assigned_role.role_id == role.id
  end

  test "preload_roles/1 takes a fetched user and preloads all the user_roles and child associations" do
    roles = insert_test_roles

    user = %User{}
    |> User.create_changeset(@valid_attrs)
    |> Repo.insert!

    Enum.each roles, fn r ->
      :ok = User.assign_role(user, r.name)
    end

    user = User.preload_roles(user)

    assert ensure_roles_are_loaded(user)
  end

  test "with_roles/1 returns a query that fetches the user and preloads all the user_roles and child associations" do
    roles = insert_test_roles

    user = %User{}
    |> User.create_changeset(@valid_attrs)
    |> Repo.insert!

    Enum.each roles, fn r ->
      :ok = User.assign_role(user, r.name)
    end

    user = User
    |> User.with_roles
    |> Repo.one!

    assert ensure_roles_are_loaded(user)
  end
end
