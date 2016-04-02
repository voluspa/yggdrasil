ExUnit.start()

repo = ~w(-r Yggdrasil.Repo --quiet)

Mix.Task.run "ecto.create", repo
Mix.Task.run "ecto.migrate", repo

run_path = Application.app_dir :yggdrasil, Path.join(["priv", "repo", "seeds.exs"])
Mix.Task.run "run", [run_path]
