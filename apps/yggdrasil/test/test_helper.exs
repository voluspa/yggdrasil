ExUnit.start()

repo = ~w(-r Yggdrasil.Repo --quiet)

Mix.Task.run "ecto.drop", repo
Mix.Task.run "ecto.create", repo
Mix.Task.run "ecto.migrate", repo
Mix.Task.run "run", ~w(apps/yggdrasil/priv/repo/seeds.exs)
