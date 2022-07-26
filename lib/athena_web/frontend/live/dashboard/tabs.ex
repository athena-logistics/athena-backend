defmodule AthenaWeb.Frontend.Dashboard.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  def tabs(assigns) do
    ~H"""
    <nav>
      <ul>
        <li class={if @active_tab == :table, do: "active"}>
          <%= "Table"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_url(
                @socket,
                AthenaWeb.Frontend.Dashboard.TableLive,
                @event
              )
          ) %>
        </li>
        <li class={if @active_tab == :item, do: "active"}>
          <%= "Item"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_url(
                @socket,
                AthenaWeb.Frontend.Dashboard.ItemLive,
                @event
              )
          ) %>
        </li>
        <li class={if @active_tab == :location, do: "active"}>
          <%= "Location"
          |> gettext
          |> link(
            to:
              Routes.frontend_logistics_live_url(
                @socket,
                AthenaWeb.Frontend.Dashboard.LocationLive,
                @event
              )
          ) %>
        </li>
      </ul>
    </nav>
    """
  end
end
