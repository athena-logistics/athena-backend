import Config

config :athena_logistics, Athena.Repo, show_sensitive_data_on_connection_error: true

config :athena_logistics, AthenaWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch",
      "--watch-options-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/athena/.*(ex)$",
      ~r"lib/athena_web/.*(ex)$",
      ~r"lib/athena_web/templates/.*(eex)$",
      ~r"lib/athena_web/.*/templates/.*(eex)$"
    ]
  ]

config :phoenix, :plug_init_mode, :runtime

config :phoenix, :stacktrace_depth, 20
