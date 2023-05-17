defmodule AthenaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use AthenaWeb, :controller
      use AthenaWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  @type resolver_result :: {:ok, term()} | {:error, term()} | {:middleware, module(), term()}

  @spec static_paths :: [String.t()]
  def static_paths, do: ~w(css fonts images js favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html],
        layouts: [html: AthenaWeb.Layouts]

      import Plug.Conn
      import AthenaWeb.Gettext
      import Phoenix.LiveView.Controller

      alias Athena.Repo

      defp render_with_navigation(conn, event, template, assigns) do
        render(
          conn,
          template,
          assigns ++
            [
              navigation: %{
                event: event,
                locations: Athena.Inventory.list_locations(event),
                item_groups: Athena.Inventory.list_item_groups(event)
              }
            ]
        )
      end

      unquote(verified_routes())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {AthenaWeb.Layouts, :app}

      alias Athena.Repo

      on_mount(AthenaWeb.SentryInit)

      defp assign_navigation(socket, event) do
        assign(socket, :navigation, %{
          event: event,
          locations: Athena.Inventory.list_locations(event),
          item_groups: Athena.Inventory.list_item_groups(event)
        })
      end

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      alias Athena.Repo

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Core UI components and translation
      import AthenaWeb.CoreComponents
      import AthenaWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  @doc false
  @spec subschema :: Macro.t()
  def subschema do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern

      import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]

      import AthenaWeb.Schema.Helpers,
        only: [many_dataloader: 0, many_dataloader: 1, payload_fields: 1]

      import AbsintheErrorPayload.Payload

      alias __MODULE__.Resolver
      alias __MODULE__.SubscriptionConfig

      alias AthenaWeb.Schema.Dataloader, as: RepoDataLoader
    end
  end

  @doc false
  @spec resolver :: Macro.t()
  def resolver do
    quote do
      import Absinthe.Resolution.Helpers
      import AthenaWeb.Schema.Helpers
      import Ecto.Query

      alias Athena.Repo
    end
  end

  @doc false
  @spec subscription_config :: Macro.t()
  def subscription_config do
    quote location: :keep do
      @type config_result ::
              {:ok, [{:topic, term | [term]}, {:context_id, term}]} | {:error, term}

      import AthenaWeb.Schema.Helpers
      import AthenaWeb.Schema.SubscriptionConfig

      alias AthenaWeb.Schema
      alias AthenaWeb.Schema.InvalidIdError
    end
  end

  @spec verified_routes :: Macro.t()
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: AthenaWeb.Endpoint,
        router: AthenaWeb.Router,
        statics: AthenaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__({which, opts}) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end
end
