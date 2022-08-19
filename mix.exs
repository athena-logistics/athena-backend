defmodule Athena.MixProject do
  use Mix.Project

  def project do
    [
      app: :athena_logistics,
      version: "0.0.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer:
        [
          # ignore_warnings: ".dialyzer_ignore.exs",
          list_unused_filters: true,
          plt_add_apps: [:mix]
        ] ++
          if System.get_env("DIALYZER_PLT_PRIV", "false") in ["1", "true"] do
            [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}]
          else
            []
          end,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "coveralls.post": :test,
        "coveralls.xml": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Athena.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "~> 1.7"},
      {:absinthe_error_payload, "1.0.1"},
      {:absinthe_graphql_ws, "~> 0.3.3"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_relay, "~> 1.5"},
      {:credo, "~> 1.4", runtime: false, only: [:dev]},
      {:dataloader, "~> 1.0"},
      {:ecto_psql_extras, "~> 0.6"},
      {:ecto_sql, "~> 3.1"},
      {:eqrcode, "~> 0.1"},
      {:ex_cldr, "~> 2.13"},
      {:ex_cldr_plugs, "~> 1.0"},
      {:excoveralls, "~> 0.4", runtime: false, only: [:test]},
      {:ex_doc, "~> 0.24", runtime: false, only: [:dev]},
      {:dialyxir, "~> 1.0", runtime: false, only: [:dev]},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:libcluster, "~> 3.0"},
      {:phoenix, "~> 1.6"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4 or ~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup":
        List.flatten([
          "ecto.create",
          "ecto.migrate",
          case Mix.env() do
            :test -> []
            _env -> ["run priv/repo/seeds.exs"]
          end
        ]),
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
