defmodule YggdrasilWeb.RegistrationController do
  use YggdrasilWeb.Web, :controller

  alias Yggdrasil.User

  @invalid_document %{title: "Invalid document.",
                      detail: "Invalid document."}

  def create(conn, %{"data" => %{"attributes" => nil}}) do
    render conn, :errors, data: @invalid_document
  end

  def create(conn, %{"data" => %{"attributes" => attributes}}) do

    case User.create_with_default_role(attributes) do
      {:ok, new_user} ->
        conn
          |> Guardian.Plug.api_sign_in(new_user)
          |> render(:show, data: new_user)
      {:error, err} ->
        render conn, :errors, data: err
    end
  end

  def create(conn, %{}) do
    render conn, :errors, data: @invalid_document
  end
end
