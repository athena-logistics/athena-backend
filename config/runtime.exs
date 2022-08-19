import Config

case config_env() do
  :prod ->
    config :athena_logistics, AthenaWeb.Endpoint, server: true

  _env ->
    nil
end

database_socket_options =
  case System.get_env("ECTO_IPV6", "false") do
    truthy when truthy in ["true", "1"] -> [:inet6]
    _falsy -> []
  end

database_ssl =
  case System.get_env("DATABASE_SSL", "false") do
    truthy when truthy in ["true", "1"] -> true
    _falsy -> false
  end

database_prepare =
  case System.get_env("DATABASE_PREPARE", "named") do
    "named" -> :named
    "unnamed" -> :unnamed
    other -> raise "Invalid value #{inspect(other)} for env DATABASE_PREPARE"
  end

database_connection_params =
  case System.get_env("DATABASE_URL") do
    nil ->
      [
        port: System.get_env("DATABASE_PORT", "5432"),
        username: System.get_env("DATABASE_USER", "root"),
        password: System.get_env("DATABASE_PASSWORD", ""),
        database: System.get_env("DATABASE_NAME", "athena_#{config_env()}"),
        hostname: System.get_env("DATABASE_HOST", "localhost")
      ]

    url ->
      [url: url]
  end

config :athena_logistics,
       Athena.Repo,
       [
         ssl: database_ssl,
         socket_options: database_socket_options,
         backoff_type: :stop,
         pool_size: String.to_integer(System.get_env("DATABASE_POOL_SIZE", "10")),
         prepare: database_prepare
       ] ++ database_connection_params

port =
  String.to_integer(
    System.get_env(
      "PORT",
      case config_env() do
        :test -> "5000"
        _env -> "4000"
      end
    )
  )

config :athena_logistics, AthenaWeb.Endpoint,
  url: [
    host: System.get_env("EXTERNAL_HOST", "localhost"),
    port: System.get_env("EXTERNAL_PORT", "#{port}"),
    scheme: System.get_env("EXTERNAL_SCHEME", "http")
  ],
  http: [
    port: port,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base:
    System.get_env(
      "SECRET_KEY_BASE",
      "E4DiijyhDsKLZ20eXlrrS/vLf3kNLWT9zH6lG+VtCnote2CLBjW4ZiwM2fayaz03"
    )

config :logger,
  level:
    String.to_existing_atom(
      System.get_env(
        "LOG_LEVEL",
        case config_env() do
          :prod -> "info"
          :dev -> "debug"
          :test -> "debug"
        end
      )
    )

config :athena_logistics, Plug.BasicAuth,
  username: System.get_env("BASIC_AUTH_USERNAME", "admin"),
  password: System.get_env("BASIC_AUTH_PASSWORD", "admin"),
  realm: System.get_env("BASIC_AUTH_REALM", "Admin Area")
