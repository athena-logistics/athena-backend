# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :athena_logistics,
  ecto_repos: [Athena.Repo],
  generators: [context_app: :athena_logistics, binary_id: true]

config :athena_logistics, Athena.Repo,
  migration_primary_key: [id: :uuid, type: :binary_id, default: {:fragment, "GEN_RANDOM_UUID()"}],
  migration_foreign_key: [column: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec, default: {:fragment, "NOW()"}]

# Configures the endpoint
config :athena_logistics, AthenaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AthenaWeb.ErrorHTML, json: AthenaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Athena.PubSub,
  live_view: [signing_salt: "rEImWHdz"]

config :athena_logistics, AthenaWeb.Gettext, default_locale: "de"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_cldr,
  default_backend: Athena.Cldr

config :sentry, enable_source_code_context: true, root_source_code_path: File.cwd!()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
