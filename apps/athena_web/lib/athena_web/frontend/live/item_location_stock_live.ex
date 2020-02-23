defmodule AthenaWeb.Frontend.ItemLocationStockLive do
  use AthenaWeb, :live

  alias Athena.Inventory

  @impl Phoenix.LiveView
  def mount(_params, %{"item_id" => item_id, "location_id" => location_id}, socket) do
    item = Inventory.get_item!(item_id)
    location = Inventory.get_location!(location_id)

    {:ok,
     socket
     |> assign(:item, item)
     |> assign(:location, location)
     |> assign(:stock, Inventory.get_item_stock(item, location))
     |> assign(:show_correction, false)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    Phoenix.View.render(AthenaWeb.Frontend.ItemLocationStockLiveView, "index.html", assigns)
  end

  @impl Phoenix.LiveView
  def handle_event("advance_consumption", %{"new_total" => new_total}, socket) do
    {:ok, _movement} =
      Inventory.create_movement(socket.assigns.item, %{
        source_location_id: socket.assigns.location.id,
        amount: socket.assigns.stock - String.to_integer(new_total)
      })

    {:noreply,
     socket
     |> assign(:stock, Inventory.get_item_stock(socket.assigns.item, socket.assigns.location))
     |> assign(:show_correction, false)}
  end

  # TODO: Handle inverse consumption (dirty cups)
  def handle_event("advance_consumption", _value, socket) do
    {:ok, _movement} =
      Inventory.create_movement(socket.assigns.item, %{
        source_location_id: socket.assigns.location.id,
        amount:
          if socket.assigns.item.inverse do
            -1
          else
            1
          end
      })

    {:noreply,
     socket
     |> assign(:stock, Inventory.get_item_stock(socket.assigns.item, socket.assigns.location))
     |> assign(:show_correction, false)}
  end

  def handle_event("toggle_show_correction", _value, socket) do
    {:noreply,
     assign(
       socket,
       :show_correction,
       not socket.assigns.show_correction
     )}
  end

  # TODO: Subscribe to changes from somewhere else
end
