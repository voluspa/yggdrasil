defmodule Yggdrasil.UserTest do
  use Yggdrasil.ModelCase

  alias Yggdrasil.User

  @valid_attrs %{username: "tester", password: "password", password_confirmation: "password"}
  @valid_attrs_upcase_user %{username: "TESTER", password: "password", password_confirmation: "password"}

  @missing_username %{password: "password", password_confirmation: "pass"}
  @missing_password %{username: "tester", password_confirmation: "password"}
  @missing_password_conf %{username: "tester", password: "password"}
  @password_mismatch %{username: "tester", password: "test", password_confirmation: "tester"}
  @password_bad_len %{username: "tester", password: "te", password_confirmation: "tester"}
  @password_conf_bad_len %{username: "tester", password: "te", password_confirmation: "te"}

  @blank_msg "can't be blank"
  @doesntmatch_msg "does not match confirmation"
  @unique_msg "has already been taken"

  @invalid_length_msg "should be at least %{count} character(s)"
  @min_count 4

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

    assert changeset.errors[:password] == {@invalid_length_msg, [count: @min_count]}
    refute changeset.valid?
  end

  test "create_changeset with password_confirmation less than min fails" do
    changeset = User.create_changeset(%User{}, @password_conf_bad_len)

    assert changeset.errors[:password_confirmation] == {@invalid_length_msg, [count: @min_count]}
    refute changeset.valid?
  end

  test "create_changeset unique username constraint" do
    # insert the user once
    user = User.create_changeset(%User{}, @valid_attrs)
    {:ok, _user} = user |> Repo.insert

    # try again to invoke unique constraint
    {error, changeset} = user |> Repo.insert
    assert changeset.errors[:username] == @unique_msg
    refute changeset.valid?
  end

  test "changset downcases username" do
    user = User.create_changeset(%User{}, @valid_attrs_upcase_user)

    assert user.changes[:username] == "tester"
  end
end
