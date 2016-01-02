defmodule PlayerTest do
  use ExUnit.Case, async: false
  alias Yggdrasil.Player
  alias Yggdrasil.Player.Registry

  test "it registers the user as online when it starts" do
    user_id = 1
    {:ok, _pid} = Player.start_link user_id, self, fn (msg) ->
      msg
    end

    assert Registry.is_online user_id
  end

  test "it uses push_msg/1 to push a welcome message" do
    user_id = 2

    # using an agent to store messages
    {:ok, agent} = Agent.start_link(fn -> [] end)

    {:ok, _pid} = Player.start_link user_id, self, fn (msg) ->
      Agent.update agent, fn (msgs) -> [msg | msgs] end
    end

    assert %{ message: "Welcome to the game" } = Agent.get(agent, fn ([msgs]) -> msgs end)
  end
end
