import Config

config :athena, Athena.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :athena, AthenaWeb.Endpoint, server: false
