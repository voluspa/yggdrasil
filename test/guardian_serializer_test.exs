defmodule Yggdrasil.GuardianSerializerTest do
  use Yggdrasil.ModelCase

  alias Yggdrasil.User
  alias Yggdrasil.GuardianSerializer

  @user %{username: "tester",
          password: "password",
          password_confirmation: "password"}

  defp insert_user() do
    {:ok, user} = Repo.insert(User.create_changeset(%User{}, @user))

    user
  end

  test "for_token with user returns ok and user:id token" do
    user = insert_user

    assert {:ok, "user:#{user.id}"} == GuardianSerializer.for_token(user)
  end

  test "for_token with nil returns expected error" do
    assert {:error, "Unknown resource type."} == GuardianSerializer.for_token(nil)
  end

  test "from_token with correct user_id returns user of that id" do
    user = insert_user

    assert user.id == GuardianSerializer.from_token("user:#{user.id}").id
  end

  test "from_token with nil returns expected error" do
    assert {:error, "Unknown resource type."} == GuardianSerializer.from_token(nil)
  end
end
