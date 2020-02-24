defmodule AthenaWeb.Frontend.LogisticsLive do
  use AthenaWeb, :live

  alias Athena.Inventory
  alias Phoenix.PubSub

  @impl Phoenix.LiveView
  def mount(%{"event" => event_id}, _session, socket) do
    PubSub.subscribe(Athena.PubSub, "event:updated:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "location:event:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "movement:event:#{event_id}")

    {:ok, update(socket, event_id)}
  end

  @impl Phoenix.LiveView
  def render(assigns),
    do: Phoenix.View.render(AthenaWeb.Frontend.LogisticsView, "overview.html", assigns)

  @impl Phoenix.LiveView
  def handle_info({action, %type{}}, socket)
      when action in [:created, :updated, :deleted] and
             type in [
               Athena.Inventory.Event,
               Athena.Inventory.Location,
               Athena.Inventory.Movement
             ] do
    {:noreply, update(socket, socket.assigns.event.id)}
  end

  defp update(socket, event_id) do
    event = Inventory.get_event!(event_id)

    socket
    |> assign(:event, event)
    |> assign(
      :table,
      event
      |> Inventory.logistics_table_query()
      |> Repo.all()
      |> Enum.map(&calculate_status/1)
    )
  end

  defp calculate_status(
         %{
           item: %{inverse: inverse},
           movement_in: movement_in,
           movement_out: movement_out,
           supply: supply,
           consumption: consumption,
           stock: stock
         } = row
       ) do
    total_in = movement_in + supply
    total_out = movement_out + consumption

    percentage =
      case total_in do
        0 -> :in_empty
        _ -> 1 / total_in * total_out
      end

    Map.put(
      row,
      :status,
      cond do
        stock in [0, 1] and not inverse -> :important
        percentage >= 0.8 and not inverse -> :important
        percentage >= 0.6 and not inverse -> :warning
        not inverse -> :normal
        stock > 5 and inverse -> :important
        stock > 2 and inverse -> :warning
        inverse -> :normal
      end
    )
  end
end
