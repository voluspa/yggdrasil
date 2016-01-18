defmodule PlayerRegistryTests do
  use ExUnit.Case, async: true
  alias Yggdrasil.Player.Registry

  test "it allows a player to registry as online" do
    user_id = 10
    assert :ok = Registry.register_player user_id, self
  end

  test "it knows if a player is online" do
    user_id = 11
    refute Registry.is_online user_id
    assert :ok = Registry.register_player user_id, self
    assert Registry.is_online user_id
  end

  test "it will not allow the same player to register twice" do
    user_id = 12

    assert :ok = Registry.register_player user_id, self

    register_task = Task.async(fn ->
      Registry.register_player user_id, self 
    end)

    assert {:error, :already_registered} = Task.await(register_task)
  end

  test "it knows when a player exits" do
    user_id = 13

    register_task = Task.async(fn ->
      Registry.register_player user_id, self
    end)

    # verify player was registered successfully
    # and make the task process exit
    assert :ok = Task.await(register_task)

    # we'll do this sync' so that the registry has a chance
    # to handle the exit message from the task
    refute Registry.is_online user_id, sync: true
  end

  test "it can return the pid for the user" do
    user_id = 14
    assert :ok = Registry.register_player user_id, self

    pid = Registry.get_player user_id

    assert is_pid(pid)
  end

  test "it returns the nil if the user is offline" do
    user_id = 15
    assert Registry.get_player(user_id) == nil
  end
end
