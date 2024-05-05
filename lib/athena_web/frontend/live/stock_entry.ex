defmodule AthenaWeb.Frontend.StockEntry do
  @moduledoc false

  use AthenaWeb, :live_component

  alias Athena.Inventory
  alias Athena.Inventory.StockEntry

  @impl Phoenix.LiveComponent
  def update_many(list) do
    preloaded_stock_entries =
      list
      |> Enum.map(fn {%{stock_entry: stock_entry}, _socket} -> stock_entry end)
      |> Repo.preload(location: [], item: [], item_group: [])

    Enum.map(list, fn {%{stock_entry: %StockEntry{location_id: location_id, item_id: item_id}} =
                         assigns, socket} ->
      socket
      |> assign(assigns)
      |> assign(
        stock_entry:
          Enum.find(
            preloaded_stock_entries,
            &match?(%StockEntry{location_id: ^location_id, item_id: ^item_id}, &1)
          )
      )
    end)
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
