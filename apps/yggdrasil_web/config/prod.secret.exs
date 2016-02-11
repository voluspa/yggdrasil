use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :yggdrasil_web, YggdrasilWeb.Endpoint,
  secret_key_base: "3iKQXpUq4J1LsqxYVgNEPs7kd7CB7TJrIQSgVBcjyaoEmWHSakEbRqXMW1dYJHrV"

# Configure your database
config :yggdrasil, Yggdrasil.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "yggdrasil_prod",
  pool_size: 20
