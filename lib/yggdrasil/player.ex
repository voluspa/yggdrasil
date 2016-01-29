defmodule Yggdrasil.Player do
  use GenServer
  alias Yggdrasil.Message
  alias Yggdrasil.Player.Supervisor
  alias Yggdrasil.Player.Registry
  alias Yggdrasil.Command

  def start_link(user_id, owner_pid, push_msg) do
    GenServer.start_link __MODULE__, [user_id, owner_pid, push_msg]
  end

  def join_game(user_id, owner_pid, push_msg) do
    Supervisor.add_player user_id, [owner_pid, push_msg]
  end

  def run_cmd(user_id, cmd) do
    # horrible terrible temporary implementation
    # room would eventually do all of this
    ctxt = %Yggdrasil.Room.Context{ player: user_id }
    ctxt = Command.execute cmd, ctxt

    Enum.each ctxt.actions,
      fn {:notify, player, message} ->
        notify(player, message)
      end
  end

  def notify(user_id, msg = %Message{}) do
    player_pid = Registry.get_player user_id
    GenServer.cast(player_pid, {:notify, msg})
  end


  def init([user_id, channel_pid, push_msg]) do
    case Registry.register_player(user_id, self) do
      :ok ->
        monitor_ref = Process.monitor channel_pid
        push_msg.(Message.info("Welcome to the game"))
        {:ok, %{
          user: user_id,
          channel: channel_pid,
          monitor: monitor_ref,
          push_msg: push_msg
        }}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_cast({:notify, msg}, state) do
    state.push_msg.(msg)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    # channel exited, lets log out the player
    {:stop, {:shutdown, :logout}, state}
  end
end
