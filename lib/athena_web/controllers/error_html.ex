defmodule AthenaWeb.ErrorHTML do
  @moduledoc false

  use AthenaWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/sample_app_web/controllers/error_html/404.html.heex
  #   * lib/sample_app_web/controllers/error_html/500.html.heex
  #
  embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, assigns), do: fallback(Map.put(assigns, :template, template))

  defp sentry_enabled?, do: not is_nil(Sentry.Config.dsn())

  # TODO: Use solution of
  # https://github.com/getsentry/sentry-elixir/issues/730
  defp dsn, do: System.get_env("SENTRY_DSN")
end
