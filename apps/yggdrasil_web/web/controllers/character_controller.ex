defmodule YggdrasilWeb.CharacterController do
  use YggdrasilWeb.Web, :controller
  use Guardian.Phoenix.Controller

  alias Yggdrasil.Character
  alias Yggdrasil.Repo, as: YggRepo

  def index(conn, _params, user, _claims) do
    user_id = user.id
    chars = YggRepo.all from c in Character,
                    where: c.ext_id == ^user_id,
                    select: c

    render conn, :show, data: chars
  end

  def show(conn, %{"char_id" => char_id}, user, _claims) do
    user_id = user.id

    # returns nil if not found
    # need to sort out what we want here.
    char = YggRepo.one from c in Character,
                    where: c.id == ^char_id and c.ext_id == ^user_id,
                    select: c

    render conn, :show, data: char
  end

  def create(conn, %{"data" => %{"attributes" => attributes}}, user, _claims) do
    attributes = Map.put attributes, "ext_id", user.id
    char = Character.changeset(%Character{}, attributes)

    case YggRepo.insert(char) do
      {:ok, new_char} ->
        render conn, :show, data: new_char
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end

  def delete(conn, %{"char_id" => char_id}, user, _claims) do
    user_id = user.id

    # returns nil if not found
    # need to sort out what we want here.
    char = YggRepo.one from c in Character,
                    where: c.id == ^char_id and c.ext_id == ^user_id,
                    select: c

    do_delete conn, char
  end

  defp do_delete(conn, nil) do
    render conn, :errors, data: %{title: "Invalid Character",
                                  detail: "Character not found for the specified user"}
  end

  defp do_delete(conn, char) do
    case YggRepo.delete(char) do
      {:ok, _char} -> 
        # http://jsonapi.org/format/#crud-deleting
        conn
        |> send_resp(:no_content, "")
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end
end
