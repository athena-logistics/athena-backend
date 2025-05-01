defmodule AthenaWeb.Frontend.Location.Tabs do
  @moduledoc false

  use AthenaWeb, :component

  attr :socket, Phoenix.LiveView.Socket, required: true
  attr :location, Athena.Inventory.Location, required: true
  attr :active_tab, :atom, required: true

  def tabs(assigns) do
    ~H"""
    <nav class="container mb-5">
      <ul class="nav nav-tabs">
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/locations/#{@location}"}
            class={["nav-link", if(@active_tab == :inventory, do: "active")]}
          >
            {gettext("Inventory")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/locations/#{@location}/missing-items"}
            class={["nav-link", if(@active_tab == :missing_items, do: "active")]}
          >
            {gettext("Missing Items")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/locations/#{@location}/expectations"}
            class={["nav-link", if(@active_tab == :expectations, do: "active")]}
          >
            {gettext("Expectations")}
          </.link>
        </li>
        <li class="nav-item">
          <.link
            navigate={~p"/logistics/locations/#{@location}/stats"}
            class={["nav-link", if(@active_tab == :stats, do: "active")]}
          >
            {gettext("Stats")}
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
