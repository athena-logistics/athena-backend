defmodule AthenaWeb.Admin.LocationController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Location

  def index(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)
    locations = Inventory.list_locations(event)

    render_with_navigation(conn, event, "index.html", event: event, locations: locations)
  end

  def new(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)

    changeset = Inventory.change_location(%Location{})

    render_with_navigation(conn, event, "new.html", changeset: changeset, event: event)
  end

  def create(conn, %{"event" => event, "location" => location_params}) do
    event = Inventory.get_event!(event)

    case Inventory.create_location(event, location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, gettext("Location created successfully."))
        |> redirect(to: ~p"/admin/locations/#{location}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, event, "new.html", changeset: changeset, event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(:event)

    render_with_navigation(conn, location.event, "show.html", location: location)
  end

  def edit(conn, %{"id" => id}) do
    location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(:event)

    changeset = Inventory.change_location(location)

    render_with_navigation(conn, location.event, "edit.html",
      location: location,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(:event)

    case Inventory.update_location(location, location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, gettext("Location updated successfully."))
        |> redirect(to: ~p"/admin/locations/#{location}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, location.event, "edit.html",
          location: location,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    %{event_id: event_id} = location = Inventory.get_location!(id)
    {:ok, _location} = Inventory.delete_location(location)

    conn
    |> put_flash(:info, gettext("Location deleted successfully."))
    |> redirect(to: ~p"/admin/events/#{event_id}/locations")
  end
end
