defmodule Yggdrasil.UserTest do
  use Yggdrasil.ModelCase

  alias Yggdrasil.User
  alias Comeonin.Bcrypt

  @min_len 4
  @password "password"
  @short_password String.slice(@password, 1..(@min_len - 1))

  @valid_attrs %{username: "tester", password: @password, password_confirmation: @password }

  @valid_attrs_upcase_user    Map.update!(@valid_attrs, :username, &String.upcase/1)
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

  # -- helpers

  defp valid_hash(hash) do
    Bcrypt.checkpw(@password, hash)
  end

  defp hash_missing?(changeset) do
    !Map.has_key?(changeset.changes, :hash)
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

  test "create_changet genreates hash if valid" do
    changeset = User.create_changeset(%User{}, @valid_attrs)

    assert Map.has_key?(changeset.changes, :hash)

    hash = changeset.changes.hash
    assert valid_hash(hash)
  end

  test "create_changet doesn't genreates hash if username missing" do
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
end
