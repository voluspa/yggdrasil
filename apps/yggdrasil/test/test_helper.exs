ExUnit.start()

Mix.Task.run "ecto.create", ~w(-r Yggdrasil.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Yggdrasil.Repo --quiet)
