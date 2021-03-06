defmodule YggdrasilWeb.Router do
  use YggdrasilWeb.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  pipeline :guardian do
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated, handler: YggdrasilWeb.GuardianErrorHandler
  end

  @docs """
  scoped so that /api/auth will not have an auth plug
  in it's pipeline
  """
  scope "/api/auth", YggdrasilWeb, as: :api_auth do
    pipe_through :api

    post "/login", SessionController, :create
    post "/register", RegistrationController, :create
  end

  @docs """
  seperate scope so all api calls that are not auth
  will be setup like this

  pipe_through :api
  pipe_through :auth

  this will mean we will not have to explicitly put plug Autneticate
  in every controller, istead if it went through this route it's protected.
  """
  scope "/api", YggdrasilWeb, as: :api do
    pipe_through :api
    pipe_through :guardian

    # not used at the moment, but setup
  end
end
