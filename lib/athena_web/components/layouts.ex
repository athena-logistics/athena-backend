defmodule AthenaWeb.Layouts do
  @moduledoc false

  use AthenaWeb, :html

  embed_templates "layouts/*"

  defp sentry_enabled?, do: not is_nil(Sentry.Config.dsn())

  # TODO: Use solution of
  # https://github.com/getsentry/sentry-elixir/issues/730
  defp dsn, do: System.get_env("SENTRY_DSN")
end
