defmodule AthenaWeb.Frontend.LogisticsLive do
  use AthenaWeb, :live

  alias Athena.Inventory
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

    sort_function =
      case sort_order do
        "asc" -> &<=/2
        "desc" -> &>=/2
      end

    socket
    |> assign(:event, event)
    |> assign(
      :table,
      event
      |> Inventory.logistics_table_query()
      |> Repo.all()
      |> Enum.map(&calculate_status/1)
      |> Enum.sort_by(
        fn row ->
          case sort_field do
            "location" ->
              row.location.name

            "item_group" ->
              row.item_group.name

            "item" ->
              row.item.name

            "supply" ->
              row.supply

            "consumption" ->
              abs(row.consumption)

            "movement_in" ->
              row.movement_in

            "movement_out" ->
              row.movement_out

            "stock" ->
              row.stock

            "status" ->
              case row.status do
                :important -> 2
                :warning -> 1
                :normal -> 0
              end
          end
        end,
        sort_function
      )
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
