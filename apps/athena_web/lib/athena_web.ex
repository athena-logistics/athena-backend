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

  def controller do
    quote do
      use Phoenix.Controller, namespace: AthenaWeb

      import Plug.Conn
      import AthenaWeb.Gettext
      import Phoenix.LiveView.Controller

      alias AthenaWeb.Router.Helpers, as: Routes

      alias Athena.Repo
    end
  end

  def view(context) do
    quote do
      use Phoenix.View,
        root: "lib/athena_web/#{String.downcase(inspect(unquote(context)))}/templates",
        namespace: Module.concat(AthenaWeb, unquote(context))

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phoenix.LiveView.Helpers

      import AthenaWeb.ErrorHelpers
      import AthenaWeb.Gettext

      alias AthenaWeb.Router.Helpers, as: Routes
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

      import Phoenix.LiveView.Helpers

      import AthenaWeb.ErrorHelpers
      import AthenaWeb.Gettext

      alias AthenaWeb.Router.Helpers, as: Routes
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
