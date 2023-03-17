defmodule AthenaWeb.Frontend.Location.MissingItemsLive do
  @moduledoc false

  use AthenaWeb, :live_view

  import Ecto.Query, only: [where: 3, preload: 2]

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.Location
  alias Athena.Inventory.StockEntry
  alias Athena.Inventory.StockExpectation
  alias Phoenix.PubSub

  @impl Phoenix.LiveView
  def mount(%{"location" => location_id}, _session, socket) do
    PubSub.subscribe(Athena.PubSub, "movement:location:#{location_id}")

    {:ok, load_location(socket, location_id)}
  end

  @impl Phoenix.LiveView
  def handle_info({action, _movement, _extra}, socket)
      when action in [:created, :updated, :deleted],
      do: {:noreply, load_location(socket, socket.assigns.location.id)}

  defp load_location(socket, id) do
    %Location{event: event} =
      location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(event: [], stock_expectations: [])

    missing_stock_entries =
      location
      |> Ecto.assoc(:stock_entries)
      |> where([stock_entry], stock_entry.missing_count > 0)
      |> preload(item: [])
      |> Repo.all()

    socket
    |> assign(location: location, missing_stock_entries: missing_stock_entries)
    |> assign_navigation(event)
  end
end
