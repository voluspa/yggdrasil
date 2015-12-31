defmodule Yggdrasil.User do
  use Yggdrasil.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  require Logger

  schema "users" do
    field :username, :string
    field :hash, :string
    field :password, :string, virtual: true # not part of table
    field :password_confirmation, :string, virtual: true # not part of table
    timestamps
  end

  @doc """
  create_changeset should be used when creating a new user it ensures
  all the fields needed are there and valid and generates a password
  """
  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(username password password_confirmation), ~w())
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
    |> validate_length(:password, min: 4)
    |> validate_length(:password_confirmation, min: 4)
    |> validate_confirmation(:password)
    |> add_password
  end

  @doc """
  update_pw_changeset shuld be used when updating a password for a user.
  it will only change the password field and ensures that username and other
  fields are not modified.
  """
  def update_pw_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(password password_confirmation), ~w())
    |> validate_length(:password, min: 4)
    |> validate_length(:password_confirmation, min: 4)
    |> validate_confirmation(:password)
    |> add_password
  end

  @doc """
  update_changeset should be used for general updates it exlcudes the hash field
  if you need to update the users password please use update_pw_changeset
  """
  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(username), ~w())
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
  end

  @doc """
  adds password at end of chain protects the hashpwsalt from seeing a nil value
  in the case of missing password field.
  """
  def add_password(changeset = %{:valid? => false}) do
    changeset
  end

  def add_password(changeset = %{:valid? => true}) do
    changeset
      |> put_change(:hash, hashpwsalt(changeset.params["password"]))
  end
end
