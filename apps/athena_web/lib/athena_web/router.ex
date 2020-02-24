defmodule AthenaWeb.Router do
  use AthenaWeb, :router

  @subresource_actions [:index, :new, :create]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :put_live_layout, {AthenaWeb.Admin.LayoutView, "app.html"}
    plug :put_layout, {AthenaWeb.Admin.LayoutView, "app.html"}
  end

  pipeline :frontend_logistics do
    plug :put_live_layout, {AthenaWeb.Frontend.LayoutView, "logistics.html"}
    plug :put_layout, {AthenaWeb.Frontend.LayoutView, "logistics.html"}
  end

  pipeline :frontend_vendor do
    plug :put_live_layout, {AthenaWeb.Frontend.LayoutView, "vendor.html"}
    plug :put_layout, {AthenaWeb.Frontend.LayoutView, "vendor.html"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AthenaWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", EventController, :index
    resources "/events", EventController, except: [:index]
    resources "/events/:event/locations", LocationController, only: @subresource_actions
    resources "/locations", LocationController, except: @subresource_actions
    resources "/events/:event/item_groups", ItemGroupController, only: @subresource_actions
    resources "/item_groups", ItemGroupController, except: @subresource_actions
    resources "/item_groups/:item_group/items", ItemController, only: @subresource_actions
    resources "/items", ItemController, except: @subresource_actions
    resources "/items/:item/movements", MovementController, only: @subresource_actions
    resources "/movements", MovementController, except: @subresource_actions
  end

  scope "/logistics/", AthenaWeb.Frontend, as: :frontend_logistics, assigns: %{access: :logistics} do
    pipe_through [:browser, :frontend_logistics]

    get "/locations/:id", LocationController, :show
    live "/events/:event/overview", LogisticsLive
  end

  scope "/vendor/", AthenaWeb.Frontend, as: :frontend_vendor, assigns: %{access: :vendor} do
    pipe_through [:browser, :frontend_vendor]

    get "/locations/:id", LocationController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", AthenaWeb do
  #   pipe_through :api
  # end
end
