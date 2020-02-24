defmodule Athena.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false

  alias Athena.Repo
  alias Athena.Inventory.Event
  alias Athena.Inventory.Movement
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Item
  alias Phoenix.PubSub

  @movement_sum from(m in Movement,
                  select: sum(m.amount)
                )

  @movement_relocations where(
                          @movement_sum,
                          [m],
                          not is_nil(m.source_location_id) and
                            not is_nil(m.destination_location_id)
                        )

  @movement_supply where(@movement_sum, [m], is_nil(m.source_location_id))

  @movement_consumption where(@movement_sum, [m], is_nil(m.destination_location_id))

  defp notify_pubsub(result, action, resource_name, modifiers \\ [])

  defp notify_pubsub({:ok, %{id: id} = result}, action, resource_name, modifiers) do
    message = {action, result}

    for modifier <- modifiers do
      :ok = PubSub.broadcast(Athena.PubSub, "#{resource_name}:#{modifier}", message)
      :ok = PubSub.broadcast(Athena.PubSub, "#{resource_name}:#{action}:#{modifier}", message)

      :ok =
        PubSub.broadcast(Athena.PubSub, "#{resource_name}:#{action}:#{id}:#{modifier}", message)
    end

    :ok = PubSub.broadcast(Athena.PubSub, "#{resource_name}", message)
    :ok = PubSub.broadcast(Athena.PubSub, "#{resource_name}:#{action}", message)
    :ok = PubSub.broadcast(Athena.PubSub, "#{resource_name}:#{action}:#{id}", message)

    {:ok, result}
  end

  defp notify_pubsub(other_result, _action, _resource_name, _modifiers), do: other_result

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events, do: Repo.all(Event)

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}),
    do:
      %Event{}
      |> change_event(attrs)
      |> Repo.insert()
      |> notify_pubsub(:created, "event")

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs),
    do:
      event
      |> change_event(attrs)
      |> Repo.update()
      |> notify_pubsub(:updated, "event")

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event),
    do:
      event
      |> Repo.delete()
      |> notify_pubsub(:deleted, "event")

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}), do: Event.changeset(event, attrs)

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations(event),
    do: event |> Ecto.assoc(:locations) |> order_by([l], l.name) |> Repo.all()

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(%Event{id: event_id} = event, attrs \\ %{}),
    do:
      event
      |> Ecto.build_assoc(:locations)
      |> change_location(attrs)
      |> Repo.insert()
      |> notify_pubsub(:created, "location", ["event:#{event_id}"])

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{event_id: event_id} = location, attrs),
    do:
      location
      |> change_location(attrs)
      |> Repo.update()
      |> notify_pubsub(:updated, "location", ["event:#{event_id}"])

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{event_id: event_id} = location),
    do:
      location
      |> Repo.delete()
      |> notify_pubsub(:deleted, "location", ["event:#{event_id}"])

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}),
    do: Location.changeset(location, attrs)

  @doc """
  Returns the list of item_groups.

  ## Examples

      iex> list_item_groups()
      [%ItemGroup{}, ...]

  """
  def list_item_groups(event), do: event |> Ecto.assoc(:item_groups) |> Repo.all()

  def list_relevant_item_groups(%Location{id: location_id}),
    do:
      Repo.all(
        from(ig in ItemGroup,
          join: i in assoc(ig, :items),
          join: m in assoc(i, :movements),
          where:
            m.source_location_id == ^location_id or m.destination_location_id == ^location_id,
          group_by: ig.id,
          order_by: ig.name
        )
      )

  @doc """
  Gets a single item_group.

  Raises `Ecto.NoResultsError` if the Item group does not exist.

  ## Examples

      iex> get_item_group!(123)
      %ItemGroup{}

      iex> get_item_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_group!(id), do: Repo.get!(ItemGroup, id)

  @doc """
  Creates a item_group.

  ## Examples

      iex> create_item_group(%{field: value})
      {:ok, %ItemGroup{}}

      iex> create_item_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_group(%Event{id: event_id} = event, attrs \\ %{}),
    do:
      event
      |> Ecto.build_assoc(:item_groups)
      |> change_item_group(attrs)
      |> Repo.insert()
      |> notify_pubsub(:created, "item_group", ["event:#{event_id}"])

  @doc """
  Updates a item_group.

  ## Examples

      iex> update_item_group(item_group, %{field: new_value})
      {:ok, %ItemGroup{}}

      iex> update_item_group(item_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_group(%ItemGroup{event_id: event_id} = item_group, attrs),
    do:
      item_group
      |> change_item_group(attrs)
      |> Repo.update()
      |> notify_pubsub(:updated, "item_group", ["event:#{event_id}"])

  @doc """
  Deletes a item_group.

  ## Examples

      iex> delete_item_group(item_group)
      {:ok, %ItemGroup{}}

      iex> delete_item_group(item_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_group(%ItemGroup{event_id: event_id} = item_group),
    do:
      item_group
      |> Repo.delete()
      |> notify_pubsub(:deleted, "item_group", ["event:#{event_id}"])

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_group changes.

  ## Examples

      iex> change_item_group(item_group)
      %Ecto.Changeset{source: %ItemGroup{}}

  """
  def change_item_group(%ItemGroup{} = item_group, attrs \\ %{}),
    do: ItemGroup.changeset(item_group, attrs)

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(%ItemGroup{} = item_group), do: item_group |> Ecto.assoc(:items) |> Repo.all()
  def list_items(%Event{} = event), do: event |> Ecto.assoc(:items) |> Repo.all()

  def list_relevant_items(%Location{id: location_id}, %ItemGroup{id: item_group_id}),
    do:
      Repo.all(
        from(i in Item,
          join: ig in assoc(i, :item_group),
          join: m in assoc(i, :movements),
          where:
            ig.id == ^item_group_id and
              (m.source_location_id == ^location_id or m.destination_location_id == ^location_id),
          group_by: i.id,
          order_by: i.name
        )
      )

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  defp get_item_movement_sum(query, %Item{id: item_id}) do
    query
    |> where([m], m.item_id == ^item_id)
    |> Repo.all()
    |> case do
      [nil] -> 0
      [sum] -> sum
    end
  end

  defp get_item_movement_sum_out(query, item, %Location{id: location_id}),
    do:
      query
      |> where([m], m.source_location_id == ^location_id)
      |> get_item_movement_sum(item)

  defp get_item_movement_sum_in(query, item, %Location{id: location_id}),
    do:
      query
      |> where([m], m.destination_location_id == ^location_id)
      |> get_item_movement_sum(item)

  def get_item_consumption(item), do: get_item_movement_sum(@movement_consumption, item)

  def get_item_consumption(item, location),
    do: get_item_movement_sum_out(@movement_consumption, item, location)

  def get_item_supply(item), do: get_item_movement_sum(@movement_supply, item)

  def get_item_supply(item, location),
    do: get_item_movement_sum_in(@movement_supply, item, location)

  def get_item_relocations(item), do: get_item_movement_sum(@movement_relocations, item)

  def get_item_relocations_out(item, location),
    do: get_item_movement_sum_out(@movement_relocations, item, location)

  def get_item_relocations_in(item, location),
    do: get_item_movement_sum_in(@movement_relocations, item, location)

  def get_item_stock(item), do: get_item_supply(item) - get_item_consumption(item)

  def get_item_stock(item, location),
    do:
      get_item_supply(item, location) - get_item_relocations_out(item, location) +
        get_item_relocations_in(item, location) - get_item_consumption(item, location)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(%{id: item_group_id, event_id: event_id} = item_group, attrs \\ %{}),
    do:
      item_group
      |> Ecto.build_assoc(:items)
      |> change_item(attrs)
      |> Repo.insert()
      |> notify_pubsub(:created, "item", ["item_group:#{item_group_id}", "event:#{event_id}"])

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{item_group_id: item_group_id} = item, attrs) do
    %{event: %{id: event_id}} = Repo.preload(item, :event)

    item
    |> change_item(attrs)
    |> Repo.update()
    |> notify_pubsub(:updated, "item", ["item_group:#{item_group_id}", "event:#{event_id}"])
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{item_group_id: item_group_id} = item) do
    %{event: %{id: event_id}} = Repo.preload(item, :event)

    item
    |> Repo.delete()
    |> notify_pubsub(:deleted, "item", ["item_group:#{item_group_id}", "event:#{event_id}"])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}), do: Item.changeset(item, attrs)

  @doc """
  Returns the list of movements.

  ## Examples

      iex> list_movements()
      [%Movement{}, ...]

  """
  def list_movements(%Location{id: location_id}),
    do:
      Repo.all(
        from m in Movement,
          where:
            m.source_location_id == ^location_id or m.destination_location_id == ^location_id,
          order_by: m.inserted_at
      )

  def list_movements(%Item{} = item), do: item |> Ecto.assoc(:movements) |> Repo.all()

  @doc """
  Gets a single movement.

  Raises `Ecto.NoResultsError` if the Movement does not exist.

  ## Examples

      iex> get_movement!(123)
      %Movement{}

      iex> get_movement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_movement!(id), do: Repo.get!(Movement, id)

  @doc """
  Creates a movement.

  ## Examples

      iex> create_movement(%{field: value})
      {:ok, %Movement{}}

      iex> create_movement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_movement(%Item{id: item_id} = item, attrs \\ %{}) do
    %{event: %{id: event_id}, item_group: %{id: item_group_id}} =
      Repo.preload(item, [:item_group, :event])

    item
    |> Ecto.build_assoc(:movements)
    |> change_movement(attrs)
    |> Repo.insert()
    |> case do
      {:ok,
       %{source_location_id: source_location_id, destination_location_id: destination_location_id} =
           movement} ->
        notify_pubsub({:ok, movement}, :created, "movement", [
          "location:#{source_location_id}",
          "location:#{destination_location_id}",
          "item:#{item_id}",
          "item_group:#{item_group_id}",
          "event:#{event_id}"
        ])

      other ->
        other
    end
  end

  @doc """
  Updates a movement.

  ## Examples

      iex> update_movement(movement, %{field: new_value})
      {:ok, %Movement{}}

      iex> update_movement(movement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_movement(%Movement{item_id: item_id} = movement, attrs) do
    %{event: %{id: event_id}, item_group: %{id: item_group_id}} =
      Repo.preload(movement, [:item_group, :event])

    movement
    |> change_movement(attrs)
    |> Repo.update()
    |> case do
      {:ok,
       %{source_location_id: source_location_id, destination_location_id: destination_location_id} =
           movement} ->
        notify_pubsub({:ok, movement}, :updated, "movement", [
          "location:#{source_location_id}",
          "location:#{destination_location_id}",
          "item:#{item_id}",
          "item_group:#{item_group_id}",
          "event:#{event_id}"
        ])

      other ->
        other
    end
  end

  @doc """
  Deletes a movement.

  ## Examples

      iex> delete_movement(movement)
      {:ok, %Movement{}}

      iex> delete_movement(movement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_movement(
        %Movement{
          item_id: item_id,
          source_location_id: source_location_id,
          destination_location_id: destination_location_id
        } = movement
      ) do
    %{event: %{id: event_id}, item_group: %{id: item_group_id}} =
      Repo.preload(movement, [:item_group, :event])

    movement
    |> Repo.delete()
    |> notify_pubsub(:deleted, "movement", [
      "location:#{source_location_id}",
      "location:#{destination_location_id}",
      "item:#{item_id}",
      "item_group:#{item_group_id}",
      "event:#{event_id}"
    ])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movement changes.

  ## Examples

      iex> change_movement(movement)
      %Ecto.Changeset{source: %Movement{}}

  """
  def change_movement(%Movement{} = movement, attrs \\ %{}),
    do: Movement.changeset(movement, attrs)

  def logistics_table_query(%Event{id: event_id}) do
    supply_query =
      from(m in Movement,
        select: %{
          item_id: m.item_id,
          amount: sum(m.amount),
          location_id: m.destination_location_id
        },
        where: is_nil(m.source_location_id),
        group_by: m.item_id,
        group_by: m.destination_location_id
      )

    consumption_query =
      from(m in Movement,
        select: %{
          item_id: m.item_id,
          amount: sum(m.amount),
          location_id: m.source_location_id
        },
        where: is_nil(m.destination_location_id),
        group_by: m.item_id,
        group_by: m.source_location_id
      )

    movement_out_query =
      from(m in Movement,
        select: %{
          item_id: m.item_id,
          amount: sum(m.amount),
          location_id: m.source_location_id
        },
        where: not is_nil(m.destination_location_id),
        group_by: m.item_id,
        group_by: m.source_location_id
      )

    movement_in_query =
      from(m in Movement,
        select: %{
          item_id: m.item_id,
          amount: sum(m.amount),
          location_id: m.destination_location_id
        },
        where: not is_nil(m.source_location_id),
        group_by: m.item_id,
        group_by: m.destination_location_id
      )

    from(e in Event,
      join: l in assoc(e, :locations),
      join: ig in assoc(e, :item_groups),
      join: i in assoc(ig, :items),
      left_join: m_supply in subquery(supply_query),
      on: m_supply.item_id == i.id and m_supply.location_id == l.id,
      left_join: m_consumption in subquery(consumption_query),
      on: m_consumption.item_id == i.id and m_consumption.location_id == l.id,
      left_join: m_out in subquery(movement_out_query),
      on: m_out.item_id == i.id and m_out.location_id == l.id,
      left_join: m_in in subquery(movement_in_query),
      on: m_in.item_id == i.id and m_in.location_id == l.id,
      having:
        count(m_supply.item_id) != 0 or count(m_consumption.item_id) != 0 or
          count(m_in.item_id) != 0 or count(m_out.item_id) != 0,
      group_by: l.id,
      group_by: ig.id,
      group_by: i.id,
      where: e.id == ^event_id,
      select: %{
        location: l,
        item_group: ig,
        item: i,
        supply: fragment("COALESCE(?, 0)", max(m_supply.amount)),
        consumption: fragment("COALESCE(?, 0)", max(m_consumption.amount)),
        movement_out: fragment("COALESCE(?, 0)", max(m_out.amount)),
        movement_in: fragment("COALESCE(?, 0)", max(m_in.amount)),
        stock:
          fragment("COALESCE(?, 0)", max(m_supply.amount)) -
            fragment("COALESCE(?, 0)", max(m_consumption.amount)) +
            fragment("COALESCE(?, 0)", max(m_in.amount)) -
            fragment("COALESCE(?, 0)", max(m_out.amount))
      },
      order_by: l.name,
      order_by: ig.name,
      order_by: i.name
    )
  end
end
