import Config

config :athena_logistics, Athena.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :athena_logistics, AthenaWeb.Endpoint,
  server: false,
  debug_errors: true
