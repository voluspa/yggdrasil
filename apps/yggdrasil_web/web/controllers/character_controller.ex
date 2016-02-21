defmodule YggdrasilWeb.CharacterController do
  use YggdrasilWeb.Web, :controller

  alias Yggdrasil.Character

  def index(conn, %{"filter" => %{"user_id" => user_id}}) do
    # this should not happen, but could easily
    # probably don't need to crash but rather return an error
    ^user_id = conn.assigns.user

    chars = Repo.all from c in Character,
                    where: c.user_id == ^user_id,
                    select: c

    render conn, :show, data: chars
  end

  def show(conn, %{"char_id" => char_id}) do
    user_id = conn.assigns.user

    # returns nil if not found
    # need to sort out what we want here.
    char = Repo.one from c in Character,
                    where: c.id == ^char_id and c.user_id == ^user_id,
                    select: c

    render conn, :show, data: char
  end

  def create(conn, %{"data" => %{"attributes" => attributes}}) do
    char = Character.changeset(%Character{}, attributes)

    case Repo.insert(char) do
      {:ok, new_char} ->
        render conn, :show, data: new_char
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end

  def delete(conn, %{"char_id" => char_id}) do
    user_id = conn.assigns.user

    # returns nil if not found
    # need to sort out what we want here.
    char = Repo.one from c in Character,
                    where: c.id == ^char_id and c.user_id == ^user_id,
                    select: c

    case Repo.delete(char)do
      {:ok, _char} -> 
        # http://jsonapi.org/format/#crud-deleting
        conn
        |> put_status(204)
        |> send_resp
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end
end
