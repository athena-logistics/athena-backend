defmodule AthenaWeb.Router do
  use AthenaWeb, :router

  import Phoenix.LiveDashboard.Router

  @subresource_actions [:index, :new, :create]

  pipeline :browser do
    plug :accepts, ["html"]

    plug :fetch_session

    plug Cldr.Plug.AcceptLanguage, cldr_backend: AthenaWeb.Cldr

    plug Cldr.Plug.SetLocale,
      apps: [:cldr, :gettext],
      from: [:query, :body, :cookie, :accept_language],
      param: "locale",
      default: "de",
      gettext: AthenaWeb.Gettext,
      cldr: AthenaWeb.Cldr

    plug Cldr.Plug.PutSession

    plug :fetch_flash
    plug :fetch_live_flash

    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :auth
    plug :put_layout, {AthenaWeb.Admin.LayoutView, "app.html"}
  end

  pipeline :frontend_logistics do
    plug :put_layout, {AthenaWeb.Frontend.LayoutView, "logistics.html"}
  end

  pipeline :frontend_vendor do
    plug :put_layout, {AthenaWeb.Frontend.LayoutView, "vendor.html"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AthenaWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    resources "/events", EventController
    resources "/events/:event/locations", LocationController, only: @subresource_actions
    resources "/locations", LocationController, except: @subresource_actions
    resources "/events/:event/item_groups", ItemGroupController, only: @subresource_actions
    resources "/item_groups", ItemGroupController, except: @subresource_actions
    resources "/item_groups/:item_group/items", ItemController, only: @subresource_actions
    resources "/items", ItemController, except: @subresource_actions
    resources "/items/:item/movements", MovementController, only: @subresource_actions
    resources "/movements", MovementController, except: @subresource_actions

    live_dashboard "/dashboard",
      metrics: {Athena.Telemetry, :dashboard_metrics},
      ecto_repos: [Athena.Repo],
      allow_destructive_actions: true
  end

  scope "/logistics/", AthenaWeb.Frontend, as: :frontend_logistics, assigns: %{access: :logistics} do
    pipe_through [:browser, :frontend_logistics]

    get "/locations/:id", LocationController, :show

    live "/events/:event/overview", LogisticsLive

    get "/events/:event/movements/supply/new", MovementController, :supply_new
    post "/events/:event/movements/supply", MovementController, :supply_create
    get "/events/:event/movements/relocate/new", MovementController, :relocate_new
    post "/events/:event/movements/relocate", MovementController, :relocate_create
  end

  scope "/vendor/", AthenaWeb.Frontend, as: :frontend_vendor, assigns: %{access: :vendor} do
    pipe_through [:browser, :frontend_vendor]

    get "/locations/:id", LocationController, :show
  end

  scope "/", AthenaWeb do
    get "/", Redirector, to: "/admin/events"
  end

  # Other scopes may use custom stacks.
  # scope "/api", AthenaWeb do
  #   pipe_through :api
  # end

  defp auth(conn, _opts),
    do: Plug.BasicAuth.basic_auth(conn, Application.fetch_env!(:athena, Plug.BasicAuth))
end
