defmodule AthenaWeb.Frontend.LocationLive do
  @moduledoc false

  use AthenaWeb, :live

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.StockEntry
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
    %Location{event: event, stock_entries: stock_entries} =
      location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(event: [], stock_entries: [item_group: [], item: []])

    item_groups =
      stock_entries
      |> Enum.map(& &1.item_group)
      |> Enum.uniq_by(& &1.id)

    socket
    |> assign(location: location, stock_entries: stock_entries, item_groups: item_groups)
    |> assign_navigation(event)
  end

  defp relevant_stock_entries(stock_entries, %ItemGroup{id: item_group_id}),
    do:
      Enum.filter(
        stock_entries,
        &(&1.item_group_id == item_group_id and
            (&1.item.inverse or (&1.movement_in > 0 or &1.supply > 0)))
      )
end
