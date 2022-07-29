defmodule AthenaWeb.Frontend.Dashboard.ItemStatsLive do
  @moduledoc false

  use AthenaWeb, :live

  alias Athena.Inventory
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
    item = item_id |> Inventory.get_item!() |> Repo.preload(event: [], stock_entries: [])

    item_totals =
      item
      |> Inventory.event_totals_by_item_query()
      |> Ecto.Query.select(
        [event_total],
        {event_total.amount, event_total.inserted_at}
      )
      |> Ecto.Query.order_by([event_total], event_total.inserted_at)
      |> Repo.all()

    assign(socket, item: item, item_totals: item_totals)
  end
end
