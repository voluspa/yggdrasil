defmodule Yggdrasil.Router do
  use Yggdrasil.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/", Yggdrasil do
    pipe_through :browser # Use the default browser stack

    get "/", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    get "/client", ClientController, :index

    resources "users", UsersController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  scope "/api", Yggdrasil, as: :api do
    pipe_through :api

    resources "users", UsersController, only: [:index, :show]
  end
end
