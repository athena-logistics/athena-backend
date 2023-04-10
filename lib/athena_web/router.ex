defmodule AthenaWeb.Router do
  use AthenaWeb, :router

  import Phoenix.LiveDashboard.Router

  @subresource_actions [:index, :new, :create]

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]

    plug :fetch_session

    plug Cldr.Plug.AcceptLanguage, cldr_backend: AthenaWeb.Cldr

    plug Cldr.Plug.PutLocale,
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
    plug :put_layout, html: {AthenaWeb.Layouts, :app}
    plug :put_root_layout, {AthenaWeb.Layouts, :admin_root}
  end

  pipeline :frontend do
    plug :put_layout, html: {AthenaWeb.Layouts, :app}
    plug :put_root_layout, {AthenaWeb.Layouts, :frontend_root}
  end

  scope "/admin", AthenaWeb.Admin, as: :admin, assigns: %{access: :admin} do
    pipe_through [:browser, :admin]

    resources "/events", EventController
    resources "/events/:event/locations", LocationController, only: @subresource_actions
    post "/events/:event/duplicate", EventController, :duplicate
    resources "/locations", LocationController, except: @subresource_actions
    resources "/events/:event/item_groups", ItemGroupController, only: @subresource_actions
    resources "/item_groups", ItemGroupController, except: @subresource_actions
    resources "/item_groups/:item_group/items", ItemController, only: @subresource_actions -- [:index]
    resources "/items", ItemController, except: @subresource_actions
    resources "/items/:item/movements", MovementController, only: @subresource_actions
    resources "/movements", MovementController, except: @subresource_actions

    live_dashboard "/dashboard",
      metrics: {Athena.Telemetry, :dashboard_metrics},
      ecto_repos: [Athena.Repo],
      allow_destructive_actions: true
  end

  scope "/logistics/", AthenaWeb.Frontend, as: :frontend_logistics, assigns: %{access: :logistics} do
    pipe_through [:browser, :frontend]

    live_session :logistics, on_mount: {AthenaWeb.LiveViewInit, access: :logistics} do
      live "/locations/:location", Location.InventoryLive, :show
      live "/locations/:location/stats", Location.StatsLive, :show
      live "/locations/:location/expectations", Location.ExpectationsLive, :show
      live "/locations/:location/missing-items", Location.MissingItemsLive, :show

      live "/events/:event/overview", Dashboard.TableLive
      live "/events/:event/overview/item", Dashboard.ItemLive
      live "/events/:event/overview/location", Dashboard.LocationLive
      live "/events/:event/overview/missing-items", Dashboard.MissingItemsLive

      live "/items/:item/overview", Dashboard.ItemStatsLive

      live "/events/:event/movements/supply", MovementLive, :supply
      live "/events/:event/movements/relocate", MovementLive, :relocate
    end
  end

  scope "/vendor/", AthenaWeb.Frontend, as: :frontend_vendor, assigns: %{access: :vendor} do
    pipe_through [:browser, :frontend]

    live_session :vendor, on_mount: {AthenaWeb.LiveViewInit, access: :vendor} do
      live "/locations/:location", Location.InventoryLive, :show
    end
  end

  scope "/", AthenaWeb do
    get "/", Redirector, to: "/admin/events"
  end

  scope "/api" do
    pipe_through [:api]

    forward(
      "/",
      Absinthe.Plug.GraphiQL,
      schema: AthenaWeb.Schema,
      socket: AthenaWeb.UserSocket,
      interface: :playground
    )
  end

  defp auth(conn, _opts),
    do: Plug.BasicAuth.basic_auth(conn, Application.fetch_env!(:athena_logistics, Plug.BasicAuth))
end
