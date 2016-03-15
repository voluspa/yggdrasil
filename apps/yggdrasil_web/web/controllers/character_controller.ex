defmodule YggdrasilWeb.CharacterController do
  use YggdrasilWeb.Web, :controller
  use Guardian.Phoenix.Controller

  alias Yggdrasil.{User, Character}
  alias YggdrasilWeb.EnsurePermission

  plug EnsurePermission, [character: [:read]] when action in [:index, :show]
  plug EnsurePermission, [character: [:write]] when action in [:create, :delete]

  def index(conn, _params, user, _claims) do
    query = if has_all?(user) do
      Character
    else
      from c in Character,
      where: c.user_id == ^user.id,
      select: c
    end

    chars = Repo.all query

    render conn, :show, data: chars
  end

  def show(conn, %{"char_id" => char_id}, user, _claims) do

    # returns nil if not found
    # need to sort out what we want here.
    query = if has_all?(user) do
      from c in Character,
      where: c.id == ^char_id,
      select: c
    else
      from c in Character,
      where: c.id == ^char_id and c.user_id == ^user.id,
      select: c
    end

    char = Repo.one query

    render conn, :show, data: char
  end

  def create(conn, %{"data" => %{"attributes" => attributes}}, user, _claims) do
    attributes = Map.put attributes, "user_id", user.id
    char = Character.changeset(%Character{}, attributes)

    case Repo.insert(char) do
      {:ok, new_char} ->
        render conn, :show, data: new_char
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end

  def delete(conn, %{"char_id" => char_id}, user, _claims) do
    query = if has_all?(user) do
      from c in Character,
      where: c.id == ^char_id,
      select: c
    else
      from c in Character,
      where: c.id == ^char_id and c.user_id == ^user.id,
      select: c
    end

    # returns nil if not found
    # need to sort out what we want here.
    char = Repo.one query

    do_delete conn, char
  end

  defp do_delete(conn, nil) do
    render conn, :errors, data: %{title: "Invalid Character",
                                  detail: "Character not found for the specified user"}
  end

  defp do_delete(conn, char) do
    case Repo.delete(char) do
      {:ok, _char} -> 
        # http://jsonapi.org/format/#crud-deleting
        conn
        |> send_resp(:no_content, "")
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end

  defp has_all?(user) do
    User.is_granted!(user, character: [:all])
  end
end
