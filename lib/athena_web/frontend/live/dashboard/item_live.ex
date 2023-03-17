defmodule AthenaWeb.Frontend.Dashboard.ItemLive do
  @moduledoc false

  use AthenaWeb, :live_view

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.StockEntry
  alias Phoenix.PubSub

  @impl Phoenix.LiveView
  def mount(%{"event" => event_id}, _session, socket) do
    event = Inventory.get_event!(event_id)

    PubSub.subscribe(Athena.PubSub, "event:updated:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "location:event:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "movement:event:#{event_id}")

    {:ok,
     socket
     |> update(event_id)
     |> assign_navigation(event)}
  end

  @impl Phoenix.LiveView
  def handle_info({action, %type{}, _extra}, socket)
      when action in [:created, :updated, :deleted] and
             type in [
               Athena.Inventory.Event,
               Athena.Inventory.Location,
               Athena.Inventory.Movement
             ] do
    {:noreply, update(socket, socket.assigns.event.id)}
  end

  defp update(socket, event_id) do
    event =
      event_id
      |> Inventory.get_event!()
      |> Repo.preload(item_groups: [], stock_entries: [item: []])

    assign(socket, event: event)
  end
end
