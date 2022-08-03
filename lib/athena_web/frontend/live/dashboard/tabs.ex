defmodule AthenaWeb.Frontend.Dashboard.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  def tabs(assigns) do
    ~H"""
    <nav class="container mb-5">
      <ul class="nav nav-tabs">
        <li class="nav-item">
          <%= "Table"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_path(
                @socket,
                AthenaWeb.Frontend.Dashboard.TableLive,
                @event
              ),
            class: ["nav-link", if(@active_tab == :table, do: "active")]
          ) %>
        </li>
        <li class="nav-item">
          <%= "Item"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_path(
                @socket,
                AthenaWeb.Frontend.Dashboard.ItemLive,
                @event
              ),
            class: ["nav-link", if(@active_tab == :item, do: "active")]
          ) %>
        </li>
        <li class="nav-item">
          <%= "Location"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_path(
                @socket,
                AthenaWeb.Frontend.Dashboard.LocationLive,
                @event
              ),
            class: ["nav-link", if(@active_tab == :location, do: "active")]
          ) %>
        </li>
      </ul>
    </nav>
    """
  end
end
