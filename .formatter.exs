[
  locals_without_parens: [
    # Phoenix.LiveViewTest
    assert_redirect: 1,
    refute_redirected: 2
  ],
  import_deps: [:ecto, :ecto_sql, :phoenix, :phoenix_live_view, :absinthe],
  inputs: [
    "{mix,.formatter}.exs",
    "*.{ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,test}/**/*.{ex,exs,heex}"
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter]
]
