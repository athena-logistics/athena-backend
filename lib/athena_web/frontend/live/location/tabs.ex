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
            to: Routes.frontend_logistics_inventory_path(@socket, :show_logistics, @location),
            class: ["nav-link", if(@active_tab == :inventory, do: "active")]
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
