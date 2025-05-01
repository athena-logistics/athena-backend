defmodule AthenaWeb.Frontend.Dashboard.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  attr :socket, Phoenix.LiveView.Socket, required: true
  attr :event, Athena.Inventory.Event, required: true
  attr :active_tab, :atom, required: true

  def tabs(assigns) do
    ~H"""
    <nav class="container mb-5">
      <ul class="nav nav-tabs">
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/events/#{@event}/overview"}
            class={["nav-link", if(@active_tab == :table, do: "active")]}
          >
            {gettext("Table")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/events/#{@event}/overview/item"}
            class={["nav-link", if(@active_tab == :item, do: "active")]}
          >
            {gettext("Item")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/events/#{@event}/overview/location"}
            class={["nav-link", if(@active_tab == :location, do: "active")]}
          >
            {gettext("Location")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/events/#{@event}/overview/missing-items"}
            class={["nav-link", if(@active_tab == :missing_items, do: "active")]}
          >
            {gettext("Missing Items")}
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
