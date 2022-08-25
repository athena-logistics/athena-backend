defmodule AthenaWeb.Frontend.Location.StatsLive do
  @moduledoc false

  use AthenaWeb, :live

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Phoenix.PubSub

  require Ecto.Query

  @impl Phoenix.LiveView
  def mount(%{"location" => location_id}, _session, socket) do
    PubSub.subscribe(Athena.PubSub, "movement:location:#{location_id}")

    {:ok, load_location(socket, location_id), temporary_assigns: [item_totals: []]}
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
      |> Repo.preload(event: [items: [], item_groups: []])

    item_totals =
      location
      |> Inventory.location_totals_by_location_query()
      |> Ecto.Query.join(
        :inner,
        [location_total],
        item_group in assoc(location_total, :item_group),
        as: :item_group
      )
      |> Ecto.Query.select(
        [location_total, item_group: item_group],
        {item_group.id, location_total.item_id, location_total.amount, location_total.inserted_at}
      )
      |> Repo.all()
      |> Enum.group_by(&elem(&1, 0), &Tuple.delete_at(&1, 0))

    socket
    |> assign(
      location: location,
      item_totals: item_totals
    )
    |> assign_navigation(event)
  end
end
