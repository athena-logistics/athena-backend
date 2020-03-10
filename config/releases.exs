import Config

config :athena, Athena.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "2"))

config :athena_web, AthenaWeb.Endpoint,
  server: true,
  url: [
    host: System.get_env("DOMAIN", System.get_env("APP_NAME", "") <> ".gigalixirapp.com"),
    port: 443,
    scheme: "https"
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.get_env("SECRET_KEY_BASE")
  ],
  force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]]

config :libcluster,
  topologies: [
    k8s_example: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        kubernetes_selector: System.get_env("LIBCLUSTER_KUBERNETES_SELECTOR"),
        kubernetes_node_basename: System.get_env("LIBCLUSTER_KUBERNETES_NODE_BASENAME")
      ]
    ]
  ]

config :athena_web, BasicAuth,
  username:
    System.get_env("BASIC_AUTH_USERNAME") ||
      raise("Set BASIC_AUTH_USERNAME env variable"),
  password:
    System.get_env("BASIC_AUTH_PASSWORD") ||
      raise("Set BASIC_AUTH_PASSWORD env variable"),
  realm: System.get_env("BASIC_AUTH_REALM", "Admin Area")
