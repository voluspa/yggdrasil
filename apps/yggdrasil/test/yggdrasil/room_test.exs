defmodule Yggdrasil.RoomTest do
  use ExUnit.Case
  alias Yggdrasil.Room

  defmodule Yggdrasil.RoomTest.Create_changeset do
    use ExUnit.Case

    test "it requires a :title" do
      cs = Room.create_changeset(%{ })

      refute cs.valid?
      assert {:title, "can't be blank"} in cs.errors
    end

    test "it requires a :description" do
      cs = Room.create_changeset(%{ })

      refute cs.valid?
      assert {:description, "can't be blank"} in cs.errors
    end

    test "it does not allow :title to be more then 120 characters long" do
      title = String.duplicate "a", 121
      cs = Room.create_changeset(%{ title: title })

      refute cs.valid?
      assert {:title, {"should be at most %{count} character(s)", count: 120}} in cs.errors
    end

    test "it defaults :is_starting to false" do
      cs = Room.create_changeset(%{ })

      refute cs.model.is_starting
    end
  end
end
