defmodule Yggdrasil.RegistrationController do
  use Yggdrasil.Web, :controller

  alias Yggdrasil.User

  @invalid_document %{title: "Invalid document.",
                      detail: "Invalid document."}

  def create(conn, %{"data" => %{"attributes" => nil}}) do
    render conn, :errors, data: @invalid_document
  end

  def create(conn, %{"data" => %{"attributes" => attributes}}) do
    changeset = User.create_changeset(%User{}, attributes)

    case Repo.insert(changeset) do
      {:ok, new_user} ->
        conn
          |> Guardian.Plug.api_sign_in(new_user)
          |> render(:show, data: new_user)
      {:error, err_changeset} ->
        render conn, :errors, data: err_changeset
    end
  end

  def create(conn, %{}) do
    render conn, :errors, data: @invalid_document
  end
end
