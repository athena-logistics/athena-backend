defmodule AthenaWeb.Frontend.Location.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  def tabs(assigns) do
    ~H"""
    <nav>
      <ul>
        <li class={if @active_tab == :inventory, do: "active"}>
          <%= "Inventory"
          |> gettext()
          |> link(to: Routes.frontend_logistics_inventory_path(@socket, :show_logistics, @location)) %>
        </li>
        <li class={if @active_tab == :stats, do: "active"}>
          <%= "Stats"
          |> gettext()
          |> link(to: Routes.frontend_logistics_stats_path(@socket, :show, @location)) %>
        </li>
      </ul>
    </nav>
    """
  end
end
