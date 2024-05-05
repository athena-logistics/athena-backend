defmodule AthenaWeb.LiveViewInit do
  @moduledoc """
  Set up LiveView
  """

  import Phoenix.Component, only: [assign: 2]

  alias Cldr.Plug.PutLocale

  require Logger

  def on_mount(opts, _params, session, socket) do
    with {:ok, socket} <- setup_access(socket, opts[:access]),
         {:ok, socket} <- setup_locale(session, socket) do
      {:cont, socket}
    end
  end

  defp setup_access(socket, access), do: {:ok, assign(socket, access: access)}

  defp setup_locale(session, socket) do
    case AthenaWeb.Cldr.validate_locale(session[PutLocale.session_key()]) do
      {:ok, locale} ->
        AthenaWeb.Cldr.put_locale(locale)
        Cldr.put_gettext_locale(locale)
        {:ok, socket}

      {:error, {Cldr.InvalidLanguageError, message}} ->
        Logger.warning("Invalid Language in Session: #{message}")
        {:ok, socket}
    end
  end
end
