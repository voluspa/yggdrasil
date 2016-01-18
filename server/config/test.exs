use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :yggdrasil, Yggdrasil.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :yggdrasil, Yggdrasil.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "yggdrasil_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure plug for json mime type
# will require plug to be recompiled
config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}
