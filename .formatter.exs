[
  import_deps: [:ecto, :phoenix, :absinthe],
  inputs: [
    "{mix,.formatter}.exs",
    "*.{ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  subdirectories: ["priv/*/migrations"]
]
