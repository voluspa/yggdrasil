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

  @doc """
  scoped so that /api/auth will not have an auth plug
  in it's pipeline
  """
  scope "/api/auth", Yggdrasil, as: :api_auth do
    pipe_through :api

    post "/register", UsersController, :create
  end

  @doc """
  seperate scope so all api calls that are not auth
  will be setup like this

  pipe_through :api
  pipe_through :auth

  this will mean we will not have to explicitly put plug Autneticate
  in every controller, istead if it went through this route it's protected.
  """
  scope "/api", Yggdrasil, as: :api do
    pipe_through :api

    resources "users", UsersController
  end
end
