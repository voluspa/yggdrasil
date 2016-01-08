defmodule Yggdrasil.GuardianSerializer do
  @behavior Guardian.Serializer

  alias Yggdrasil.Repo
  alias Yggdrasil.User

  def for_token(user = %User{}), do: {:ok, "user:#{user.id}"}
  def for_token(_), do: {:error, "uknown resource type"}

  def from_token("user:" <> user_id), do: {:ok, Repo.get(User, user_id)}
  def from_token(_), do: {:error, "uknown resource type"}
end
