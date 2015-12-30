defmodule Yggdrasil.UserTest do
  use Yggdrasil.ModelCase

  alias Yggdrasil.User

  @valid_attrs %{username: "some content", password: "password", password_confirmation: "password"}
  @invalid_attrs %{username: "some content", password: "password", password_confirmation: "pass"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
