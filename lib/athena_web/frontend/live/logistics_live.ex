defmodule AthenaWeb.Frontend.LogisticsLive do
  @moduledoc false

  use AthenaWeb, :live

  alias Athena.Inventory
  alias Athena.Inventory.Movement
  alias Phoenix.PubSub

  @impl Phoenix.LiveView
  def mount(%{"event" => event_id}, _session, socket) do
    event = Inventory.get_event!(event_id)

    PubSub.subscribe(Athena.PubSub, "event:updated:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "location:event:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "movement:event:#{event_id}")

    {:ok,
     socket
     |> assign(:sort, {"status", "desc"})
     |> update(event_id)
     |> assign_navigation(event)}
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

  @impl Phoenix.LiveView
  def handle_event("change_sort", %{"name" => sort_name}, socket) do
    sort =
      case {sort_name, socket.assigns.sort} do
        {sort_name, {sort_name, "asc"}} -> {sort_name, "desc"}
        {sort_name, {sort_name, "desc"}} -> {sort_name, "asc"}
        {sort_name, _} -> {sort_name, "asc"}
      end

    {:noreply,
     socket
     |> assign(:sort, sort)
     |> update(socket.assigns.event.id)}
  end

  defp update(socket, event_id) do
    event = Inventory.get_event!(event_id)
    {sort_field, sort_order} = socket.assigns.sort

    socket
    |> assign(:event, event)
    |> assign(
      :table,
      event
      |> Inventory.logistics_table_query()
      |> Repo.all()
      |> Enum.map(&Map.put(&1, :status, Movement.stock_status(&1)))
      |> Enum.sort_by(
        &sort_by(sort_field, &1),
        case sort_order do
          "asc" -> &<=/2
          "desc" -> &>=/2
        end
      )
    )
  end

  defp sort_by(field, row)
  defp sort_by("location", row), do: row.location.name
  defp sort_by("item_group", row), do: row.item_group.name
  defp sort_by("item", row), do: row.item.name
  defp sort_by("supply", row), do: row.supply
  defp sort_by("consumption", row), do: abs(row.consumption)
  defp sort_by("movement_in", row), do: row.movement_in
  defp sort_by("movement_out", row), do: row.movement_out
  defp sort_by("stock", row), do: row.stock

  defp sort_by("status", row) do
    case row.status do
      :important -> 2
      :warning -> 1
      :normal -> 0
    end
  end
end
