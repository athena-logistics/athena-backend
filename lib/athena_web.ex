defmodule AthenaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AthenaWeb, :controller
      use AthenaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @type resolver_result :: {:ok, term()} | {:error, term()} | {:middleware, module(), term()}

  def controller do
    quote do
      use Phoenix.Controller, namespace: AthenaWeb

      import Plug.Conn
      import AthenaWeb.Gettext
      import Phoenix.LiveView.Controller

      alias AthenaWeb.Router.Helpers, as: Routes

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
    end
  end

  def view(context) do
    quote do
      use Phoenix.View,
        root: "lib/athena_web/#{String.downcase(inspect(unquote(context)))}/templates",
        namespace: Module.safe_concat(AthenaWeb, unquote(context))

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      unquote(view_helpers())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/athena_web/templates",
        namespace: AthenaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AthenaWeb.Gettext
    end
  end

  def live do
    quote do
      use Phoenix.LiveView

      alias Athena.Repo

      unquote(view_helpers())

      defp assign_navigation(socket, event) do
        assign(socket, :navigation, %{
          event: event,
          locations: Athena.Inventory.list_locations(event),
          item_groups: Athena.Inventory.list_item_groups(event)
        })
      end
    end
  end

  @doc false
  @spec subschema :: Macro.t()
  def subschema do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern

      import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]
      import AthenaWeb.Schema.Helpers, only: [many_dataloader: 0, payload_fields: 1]
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

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import AthenaWeb.ErrorHelpers
      import AthenaWeb.Gettext

      alias AthenaWeb.Router.Helpers, as: Routes
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
