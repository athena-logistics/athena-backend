defmodule AthenaWeb.Frontend.StockEntry do
  @moduledoc false

  use AthenaWeb, :live_component

  alias Athena.Inventory

  @impl Phoenix.LiveComponent
  def preload(list_of_assigns) do
    preloaded_stock_entries =
      list_of_assigns
      |> Enum.map(& &1.stock_entry)
      |> Repo.preload(location: [], item: [], item_group: [])

    Enum.zip_with(list_of_assigns, preloaded_stock_entries, &Map.put(&1, :stock_entry, &2))
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, changed: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("advance_consumption", %{"new_total" => new_total}, socket) do
    {:ok, _movement} =
      Inventory.create_movement(socket.assigns.stock_entry.item, %{
        source_location_id: socket.assigns.stock_entry.location.id,
        amount: socket.assigns.stock_entry.stock - String.to_integer(new_total)
      })

    {:noreply, assign(socket, changed: false)}
  end

  def handle_event("advance_consumption", %{"delta" => delta}, socket) do
    {:ok, _movement} =
      Inventory.create_movement(socket.assigns.stock_entry.item, %{
        source_location_id: socket.assigns.stock_entry.location.id,
        amount: delta
      })

    {:noreply, assign(socket, changed: false)}
  end

  def handle_event("change", _meta, socket), do: {:noreply, assign(socket, changed: true)}
  def handle_event("reset", _meta, socket), do: {:noreply, assign(socket, changed: false)}
end
