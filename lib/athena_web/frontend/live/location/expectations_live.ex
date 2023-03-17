defmodule AthenaWeb.Frontend.Location.ExpectationsLive do
  @moduledoc false

  use AthenaWeb, :live_view

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.StockExpectation
  alias Ecto.Changeset
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

  @impl Phoenix.LiveView
  def handle_event(
        "validate",
        %{"stock_expectation" => %{"item_id" => item_id} = attrs} = _params,
        socket
      ) do
    %Item{} =
      item =
      socket.assigns.location.event.item_groups
      |> Enum.flat_map(& &1.items)
      |> Enum.find(&match?(%Item{id: ^item_id}, &1))

    {:noreply,
     assign(socket,
       changesets:
         Map.put(socket.assigns.changesets, item_id, %Changeset{
           changeset(socket.assigns.location, item, attrs)
           | action: :validate
         })
     )}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "delete",
        %{"id" => stock_expectation_id} = _params,
        socket
      ) do
    {:ok, _stock_expectation} =
      socket.assigns.location.stock_expectations
      |> Enum.find(&match?(%StockExpectation{id: ^stock_expectation_id}, &1))
      |> Inventory.delete_stock_expectation()

    {:noreply, load_location(socket, socket.assigns.location.id)}
  end

  def handle_event(
        "save",
        %{"stock_expectation" => %{"item_id" => item_id} = attrs} = _params,
        socket
      ) do
    %Item{} =
      item =
      socket.assigns.location.event.item_groups
      |> Enum.flat_map(& &1.items)
      |> Enum.find(&match?(%Item{id: ^item_id}, &1))

    case Inventory.upsert_stock_expectation(item, socket.assigns.location, attrs) do
      {:ok, _stock_entry} ->
        {:noreply, load_location(socket, socket.assigns.location.id)}

      {:error, changeset} ->
        {:noreply,
         assign(socket, changesets: Map.put(socket.assigns.changesets, item_id, changeset))}
    end
  end

  defp load_location(socket, id) do
    %Location{event: event} =
      location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(event: [item_groups: [items: []]], stock_expectations: [])

    changesets =
      for %ItemGroup{} = item_group <- event.item_groups,
          %Item{} = item <- item_group.items,
          into: %{} do
        {item.id, changeset(location, item)}
      end

    socket
    |> assign(location: location, changesets: changesets)
    |> assign_navigation(event)
  end

  defp changeset(location, %Item{id: item_id} = item, attrs \\ %{}) do
    case Enum.find(
           location.stock_expectations,
           &match?(%StockExpectation{item_id: ^item_id}, &1)
         ) do
      nil ->
        Inventory.change_new_stock_expectation(item, location, attrs)

      %StockExpectation{} = stock_expectation ->
        Inventory.change_stock_expectation(stock_expectation, attrs)
    end
  end
end
