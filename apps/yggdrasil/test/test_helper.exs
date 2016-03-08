ExUnit.start()

repo = ~w(-r Yggdrasil.Repo --quiet)

Mix.Task.run "ecto.create", repo
Mix.Task.run "ecto.migrate", repo

run_path = Path.join([__DIR__, "..", "priv", "repo", "seeds.exs"])
Mix.Task.run "run", [run_path]
