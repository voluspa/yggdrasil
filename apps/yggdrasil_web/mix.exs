defmodule YggdrasilWeb.Mixfile do
  use Mix.Project

  def project do
    [app: :yggdrasil_web,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {YggdrasilWeb, []},
     applications: [:phoenix, :postgrex, :phoenix_html,
                    :cowboy, :logger, :gettext, :yggdrasil]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:yggdrasil, in_umbrella: true},
     {:phoenix, "~> 1.1.1"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 2.0"},
     {:ja_serializer, "~> 0.6.1"},
     {:guardian, "~> 0.9.0"},
     {:postgrex, ">= 0.0.0"},
     {:cors_plug, "~> 0.1.4"},
     {:excoveralls, "~>0.5.1"}
   ]
  end
end
