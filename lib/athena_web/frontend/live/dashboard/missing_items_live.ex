defmodule AthenaWeb.Frontend.Dashboard.MissingItemsLive do
  @moduledoc false

  use AthenaWeb, :live

  import Ecto.Query, only: [where: 3, preload: 2]

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.Location
  alias Athena.Inventory.StockEntry
  alias Athena.Inventory.StockExpectation
  alias Phoenix.PubSub

  @impl Phoenix.LiveView
  def mount(%{"event" => event_id}, _session, socket) do
    PubSub.subscribe(Athena.PubSub, "movement:event:#{event_id}")

    {:ok, load_event(socket, event_id)}
  end

  @impl Phoenix.LiveView
  def handle_info({action, _movement, _extra}, socket)
      when action in [:created, :updated, :deleted],
      do: {:noreply, load_event(socket, socket.assigns.event.id)}

  defp load_event(socket, id) do
    event = id |> Inventory.get_event!() |> Repo.preload(stock_expectations: [])

    missing_stock_entries =
      event
      |> Ecto.assoc(:stock_entries)
      |> where([stock_entry], stock_entry.missing_count > 0)
      |> preload(item: [], location: [])
      |> Repo.all()

    socket
    |> assign(event: event, missing_stock_entries: missing_stock_entries)
    |> assign_navigation(event)
  end
end
