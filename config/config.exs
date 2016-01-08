# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :yggdrasil, Yggdrasil.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "5t7ODk6J7ixv/64cq5hAObI8PRnzp334PYcGgt15ktmI2F4XcpaAHGDvwvT3sgEp",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Yggdrasil.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Configure plug for json mime type
# will require plug to be recompiled
config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Yggdrasil",
  ttl: { 1, :days },
  verify_issuer: true, # optional
  secret_key: "5t7ODk6J7ixv/64cq5hAObI8PRnzp334PYcGgt15ktmI2F4XcpaAHGDvwvT3sgEp",
  serializer: Yggdrasil.GuardianSerializer
