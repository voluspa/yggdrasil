use Mix.Config

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
