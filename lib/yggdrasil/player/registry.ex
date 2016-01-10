defmodule Yggdrasil.Player.Registry do
  use GenServer

  @registry_ets :player_registry_ets

  def start_link() do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def register_player(user_id, player_pid) do
    GenServer.call __MODULE__, {:register, user_id, player_pid}
  end

  def is_online(user_id, options \\ [])
  def is_online(user_id, options) do
    sync = Keyword.get(options, :sync, false)

    if sync do
        GenServer.call __MODULE__, {:is_online, user_id}
    else
        do_is_online user_id
    end
  end

  def get_player(user_id, options \\ [])
  def get_player(user_id, options) do
    sync = Keyword.get(options, :sync, false)

    if sync do
        GenServer.call __MODULE__, {:get_player, user_id}
    else
        do_get_player user_id
    end
  end


  def init([]) do
    table_id = :ets.new @registry_ets, [:named_table, :set]
    {:ok, %{
      :table_id => table_id,
      :mon2user => %{ }
    }}
  end

  def handle_call({:register, user_id, player_pid}, _from, state) do
    case :ets.lookup @registry_ets, user_id do
      [] ->
        :ets.insert @registry_ets, {user_id, player_pid}
        monitor = Process.monitor player_pid
        {:reply, :ok, add_mon2user(state, monitor, user_id)}
      [_] ->
        {:reply, {:error, :already_registered}, state}
    end
  end

  def handle_call({:is_online, user_id}, _from, state) do
    {:reply, do_is_online(user_id), state}
  end

  def handle_call({:get_player, user_id}, _from, state) do
    {:reply, do_get_player(user_id), state}
  end

  def handle_info({:DOWN, monitor, :process, _pid, _reason}, state) do
    :ets.delete @registry_ets, state.mon2user[monitor]
    {:noreply, remove_mon2user(state, monitor)}
  end


  defp add_mon2user(state, monitor, user_id) do
    %{ state | :mon2user => Map.put(state.mon2user, monitor, user_id)}
  end

  defp remove_mon2user(state, monitor) do
    %{ state | :mon2user => Map.delete(state.mon2user, monitor)}
  end

  defp do_is_online(user_id) do
    case do_get_player(user_id) do
      nil -> false
      _pid -> true
    end
  end

  defp do_get_player(user_id) do
    case :ets.lookup @registry_ets, user_id do
      [] -> nil
      [{^user_id, player_pid}] -> player_pid
    end
  end
end
