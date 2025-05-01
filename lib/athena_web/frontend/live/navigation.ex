defmodule AthenaWeb.Frontend.Navigation do
  @moduledoc false

  use AthenaWeb, :component

  alias Athena.Inventory.Location

  attr :conn, Plug.Conn, required: true
  attr :event, Athena.Inventory.Event, required: true
  attr :locations, :list, required: true

  def navigation(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg navbar-light bg-primary mb-5">
      <div class="container-fluid">
        <a href={~p"/logistics/events/#{@event}/overview"} class="navbar-brand">
          <img src={~p"/images/icon.png"} width="30" />
          {@event.name}
        </a>
        <label
          for="toggle-nav"
          class="navbar-toggler"
          type="button"
          aria-controls="navbarNavDropdown"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon"></span>
        </label>
        <input type="checkbox" id="toggle-nav" hidden />
        <main class="navbar-collapse" id="navbarNavDropdown">
          <ul class="navbar-nav">
            <li class="nav-item">
              <.link navigate={~p"/logistics/events/#{@event}/overview"} class="nav-link">
                {gettext("Logistics Overview")}
              </.link>
            </li>
            <li class="nav-item">
              <.link navigate={~p"/logistics/events/#{@event}/movements/supply"} class="nav-link">
                {gettext("Supply Item")}
              </.link>
            </li>
            <li class="nav-item">
              <.link navigate={~p"/logistics/events/#{@event}/movements/relocate"} class="nav-link">
                {gettext("Move Item")}
              </.link>
            </li>

            <li class="nav-item dropdown">
              <label
                class="nav-link dropdown-toggle"
                for="toggle-nav-locations"
                role="button"
                aria-expanded="false"
              >
                {gettext("Locations")}
              </label>
              <input type="checkbox" id="toggle-nav-locations" hidden class="toggle-dropdown" />
              <ul class="dropdown-menu show">
                <li :for={%Location{name: location_name} = location <- @locations} class="nav-item">
                  <.link navigate={~p"/logistics/locations/#{location}"} class="dropdown-item">
                    {location_name}
                  </.link>
                </li>
              </ul>
            </li>
          </ul>
        </main>
      </div>
    </nav>
    """
  end
end
