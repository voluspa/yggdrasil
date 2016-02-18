use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :yggdrasil_web, YggdrasilWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure plug for json mime type
# will require plug to be recompiled
config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}
