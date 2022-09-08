defmodule AthenaWeb.Frontend.Location.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  def tabs(assigns) do
    ~H"""
    <nav class="container mb-5">
      <ul class="nav nav-tabs">
        <li class="nav-item">
          <%= "Inventory"
          |> gettext()
          |> link(
            to: Routes.frontend_logistics_inventory_path(@socket, :show, @location),
            class: ["nav-link", if(@active_tab == :inventory, do: "active")]
          ) %>
        </li>
        <li class="nav-item">
          <%= "Missing Items"
          |> gettext()
          |> link(
            to: Routes.frontend_logistics_missing_items_path(@socket, :show, @location),
            class: ["nav-link", if(@active_tab == :missing_items, do: "active")]
          ) %>
        </li>
        <li class="nav-item">
          <%= "Expectations"
          |> gettext()
          |> link(
            to: Routes.frontend_logistics_expectations_path(@socket, :show, @location),
            class: ["nav-link", if(@active_tab == :expectations, do: "active")]
          ) %>
        </li>
        <li class="nav-item">
          <%= "Stats"
          |> gettext()
          |> link(
            to: Routes.frontend_logistics_stats_path(@socket, :show, @location),
            class: ["nav-link", if(@active_tab == :stats, do: "active")]
          ) %>
        </li>
      </ul>
    </nav>
    """
  end
end
