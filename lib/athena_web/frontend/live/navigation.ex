defmodule AthenaWeb.Frontend.Navigation do
  @moduledoc false

  use AthenaWeb, :component

  alias Athena.Inventory.Location

  def navigation(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg navbar-light bg-primary mb-5">
      <div class="container-fluid">
        <a
          href={
            Routes.frontend_logistics_live_path(@conn, AthenaWeb.Frontend.Dashboard.TableLive, @event)
          }
          class="navbar-brand"
        >
          <img src={Routes.static_path(@conn, "/images/icon.png")} width="30" />
          <%= @event.name %>
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
              <%= "Logistics Overview"
              |> gettext
              |> link(
                to:
                  Routes.frontend_logistics_live_url(
                    @conn,
                    AthenaWeb.Frontend.Dashboard.TableLive,
                    @event
                  ),
                class: "nav-link"
              ) %>
            </li>
            <li class="nav-item">
              <%= "Supply Item"
              |> gettext
              |> link(
                to: Routes.frontend_logistics_movement_url(@conn, :supply, @event),
                class: "nav-link"
              ) %>
            </li>
            <li class="nav-item">
              <%= "Move Item"
              |> gettext
              |> link(
                to: Routes.frontend_logistics_movement_url(@conn, :relocate, @event),
                class: "nav-link"
              ) %>
            </li>

            <li class="nav-item dropdown">
              <label
                class="nav-link dropdown-toggle"
                for="toggle-nav-locations"
                role="button"
                aria-expanded="false"
              >
                <%= gettext("Locations") %>
              </label>
              <input type="checkbox" id="toggle-nav-locations" hidden class="toggle-dropdown" />
              <ul class="dropdown-menu show">
                <%= for %Location{name: location_name} = location <- @locations do %>
                  <li class="nav-item">
                    <%= link(location_name,
                      to:
                        Routes.frontend_logistics_inventory_path(
                          @conn,
                          :show_logistics,
                          location
                        ),
                      class: "dropdown-item"
                    ) %>
                  </li>
                <% end %>
              </ul>
            </li>
          </ul>
        </main>
      </div>
    </nav>
    """
  end
end
