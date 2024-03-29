defmodule AthenaWeb.Admin.EventController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Event

  def index(conn, _params) do
    events = Inventory.list_events()

    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Inventory.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    case Inventory.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event created successfully."))
        |> redirect(to: ~p"/admin/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def duplicate(conn, %{"event" => id}) do
    id
    |> Inventory.get_event!()
    |> Inventory.duplicate_event()
    |> case do
      {:ok, new_event} ->
        conn
        |> put_flash(:info, gettext("Event duplicated"))
        |> redirect(to: ~p"/admin/events/#{new_event}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, gettext("Event couldn't be duplicated"))
        |> redirect(to: ~p"/admin/events")
    end
  end

  def show(conn, %{"id" => id}) do
    event = Inventory.get_event!(id)
    render_with_navigation(conn, event, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Inventory.get_event!(id)
    changeset = Inventory.change_event(event)
    render_with_navigation(conn, event, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Inventory.get_event!(id)

    case Inventory.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event updated successfully."))
        |> redirect(to: ~p"/admin/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, event, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Inventory.get_event!(id)
    {:ok, _event} = Inventory.delete_event(event)

    conn
    |> put_flash(:info, gettext("Event deleted successfully."))
    |> redirect(to: ~p"/admin/events")
  end
end
