defmodule AthenaWeb.Frontend.MovementController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Movement

  def supply_new(conn, params), do: new(conn, params, "supply_new.html")
  def supply_create(conn, params), do: create(conn, params, "supply_new.html")
  def relocate_new(conn, params), do: new(conn, params, "relocate_new.html")
  def relocate_create(conn, params), do: create(conn, params, "relocate_new.html")

  defp new(conn, %{"event" => event_id}, template) do
    event = Inventory.get_event!(event_id)
    locations = Inventory.list_locations(event)

    item_groups =
      event
      |> Inventory.list_item_groups()
      |> Enum.map(&{&1, Inventory.list_items(&1)})

    changeset = Inventory.change_movement(%Movement{})

    render_with_navigation(conn, event, template,
      item_groups: item_groups,
      event: event,
      locations: locations,
      changeset: changeset
    )
  end

  defp create(conn, %{"event" => event_id, "movement" => movement_params}, template) do
    event = Inventory.get_event!(event_id)
    locations = Inventory.list_locations(event)

    item_groups =
      event
      |> Inventory.list_item_groups()
      |> Enum.map(&{&1, Inventory.list_items(&1)})

    case Inventory.create_movement_directly(movement_params) do
      {:ok, _movement} ->
        conn
        |> put_flash(:info, gettext("Movement created successfully."))
        |> redirect(
          to: Routes.frontend_logistics_live_path(conn, AthenaWeb.Frontend.LogisticsLive, event)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, event, template,
          item_groups: item_groups,
          event: event,
          locations: locations,
          changeset: changeset
        )
    end
  end
end
