use Mix.Config

# Configure your database
config :yggdrasil, Yggdrasil.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "yggdrasil_dev",
  hostname: "localhost",
  pool_size: 10

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
