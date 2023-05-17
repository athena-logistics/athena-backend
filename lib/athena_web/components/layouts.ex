defmodule AthenaWeb.Layouts do
  @moduledoc false

  use AthenaWeb, :html

  embed_templates "layouts/*"

  defp sentry_enabled?,
    do: Sentry.Config.environment_name() in Sentry.Config.included_environments()
end
