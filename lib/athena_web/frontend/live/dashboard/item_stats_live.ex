defmodule AthenaWeb.Frontend.Dashboard.ItemStatsLive do
  @moduledoc false

  use AthenaWeb, :live

  alias Athena.Inventory
  alias Athena.Inventory.Event.OrderOverview
  alias Athena.Inventory.Location
  alias Phoenix.PubSub

  require Ecto.Query

  @impl Phoenix.LiveView
  def mount(%{"item" => item_id}, _session, socket) do
    item = item_id |> Inventory.get_item!() |> Repo.preload(event: [])

    PubSub.subscribe(Athena.PubSub, "event:updated:#{item.event.id}")
    PubSub.subscribe(Athena.PubSub, "movement:event:#{item.event.id}")

    {:ok,
     socket
     |> update(item_id)
     |> assign_navigation(item.event), temporary_assigns: [item_totals: []]}
  end

  @impl Phoenix.LiveView
  def handle_info({action, %type{}, _extra}, socket)
      when action in [:created, :updated, :deleted] and
             type in [
               Athena.Inventory.Event,
               Athena.Inventory.Location,
               Athena.Inventory.Movement
             ] do
    {:noreply, update(socket, socket.assigns.item.id)}
  end

  defp update(socket, item_id) do
    item = item_id |> Inventory.get_item!() |> Repo.preload(event: [])

    location_totals =
      item
      |> Inventory.location_totals_by_item_query()
      |> Inventory.location_totals_by_event_query(item.event)
      |> Ecto.Query.join(:inner, [location_total], location in assoc(location_total, :location),
        as: :location
      )
      |> Ecto.Query.select(
        [location_total, location: location],
        {location.name, location_total.amount, location_total.date}
      )
      |> Ecto.Query.order_by([location_total], location_total.date)
      |> Repo.all()

    item_totals =
      item
      |> Inventory.event_totals_by_item_query()
      |> Ecto.Query.select(
        [event_total],
        {event_total.amount, event_total.date}
      )
      |> Ecto.Query.order_by([event_total], event_total.date)
      |> Repo.all()

    order_overview =
      item
      |> Inventory.event_order_overview_by_item_query()
      |> Ecto.Query.order_by([order_overview], [
        is_nil(order_overview.date),
        order_overview.type,
        order_overview.date,
        order_overview.location_id
      ])
      |> Ecto.Query.preload(location: [], item: [], item_group: [])
      |> Repo.all()

    assign(socket,
      item: item,
      location_totals: location_totals,
      item_totals: item_totals,
      order_overview: order_overview
    )
  end

  defp order_overview_type_label(type)
  defp order_overview_type_label(:supply), do: gettext("Supply")
  defp order_overview_type_label(:consumption), do: gettext("Consumption")
end
