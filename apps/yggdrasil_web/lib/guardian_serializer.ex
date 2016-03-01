defmodule YggdrasilWeb.GuardianSerializer do
  @behaviour Guardian.Serializer

  require Ecto.Query
  import Ecto.Query, only: [from: 1, from: 2]

  alias Yggdrasil.{Repo, User, Role}

  def for_token(user = %User{}), do: {:ok, "user:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type."}

  def from_token("user:" <> user_id) do
    user = User
    |> User.with_role
    |> Repo.get!(user_id)

    {:ok, user}
  end
  def from_token(_), do: {:error, "Unknown resource type."}
end
