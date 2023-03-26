defmodule Athena.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockExpectation
  alias Athena.Repo
  alias Ecto.Multi
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

  defp notify_pubsub(result, action, resource_name, modifiers \\ [], extra \\ %{})

  defp notify_pubsub({:ok, %{id: id} = result}, action, resource_name, modifiers, extra) do
    message = {action, result, extra}

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

  defp notify_pubsub(other_result, _action, _resource_name, _modifiers, _extra), do: other_result

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
  Gets a single event by name.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event_by_name("Aufgetischt")
      %Event{}

      iex> get_event_by_name("")
      nil

  """
  def get_event_by_name(name), do: Repo.get_by(Event, name: name)

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
  Duplicates an event.

  ## Examples

      iex> duplicate_event(event, attrs)
      {:ok, %Event{}}

      iex> duplicate_event(event, attrs)
      {:error, %Ecto.Changeset{}}
  """
  @spec duplicate_event(old_event :: Event.t(), new_name :: String.t() | nil) ::
          {:ok, Event.t()} | {:error, reason :: any()}

  def duplicate_event(old_event, new_name \\ nil)

  def duplicate_event(old_event, nil),
    do: duplicate_event(old_event, get_unique_event_name(old_event.name))

  def duplicate_event(%Event{} = old_event, new_name) do
    Multi.new()
    |> Multi.insert(
      :event,
      change_event(%Event{
        old_event
        | name: new_name,
          id: nil,
          inserted_at: nil,
          updated_at: nil
      })
    )
    |> Multi.insert_all(:locations, Location, fn %{event: %Event{id: new_event_id}} ->
      from(location in Ecto.assoc(old_event, :locations),
        select: %{
          name: location.name,
          event_id: type(^new_event_id, Ecto.UUID)
        }
      )
    end)
    |> Multi.insert_all(:item_groups, ItemGroup, fn %{event: %Event{id: new_event_id}} ->
      from(item_group in Ecto.assoc(old_event, :item_groups),
        select: %{
          name: item_group.name,
          event_id: type(^new_event_id, Ecto.UUID)
        }
      )
    end)
    |> Multi.insert_all(:items, Item, fn %{event: %Event{} = new_event} ->
      from(item in Ecto.assoc(old_event, :items),
        join: old_item_group in assoc(item, :item_group),
        join: new_item_group in subquery(Ecto.assoc(new_event, :item_groups)),
        on: new_item_group.name == old_item_group.name,
        select: %{
          name: item.name,
          inverse: item.inverse,
          unit: item.unit,
          item_group_id: new_item_group.id
        }
      )
    end)
    |> Multi.insert_all(:stock_expectation, StockExpectation, fn %{event: %Event{} = new_event} ->
      from(stock_expectation in Ecto.assoc(old_event, :stock_expectations),
        join: old_location in assoc(stock_expectation, :location),
        join: new_location in subquery(Ecto.assoc(new_event, :locations)),
        on: new_location.name == old_location.name,
        join: old_item in assoc(stock_expectation, :item),
        join: new_item in subquery(Ecto.assoc(new_event, :items)),
        on: new_item.name == old_item.name,
        select: %{
          warning_threshold: stock_expectation.warning_threshold,
          important_threshold: stock_expectation.important_threshold,
          location_id: new_location.id,
          item_id: new_item.id
        }
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{event: event}} -> {:ok, event}
      {:error, reason} -> {:error, reason}
      {:error, _name, reason, _multi_state} -> {:error, reason}
    end
    |> notify_pubsub(:created, "event")
  end

  @copy_name_regex ~r/.*Copy \((\d+)\)$/

  defp get_unique_event_name(name) do
    event = get_event_by_name(name)

    cond do
      is_nil(event) ->
        name

      String.ends_with?(name, "Copy") ->
        get_unique_event_name(name <> " (1)")

      String.match?(name, @copy_name_regex) ->
        [_all, n] = Regex.run(@copy_name_regex, name)
        new_num = String.to_integer(n) + 1
        new_name = String.replace(name, ~r/\(\d+\)$/, "(#{new_num})")
        get_unique_event_name(new_name)

      true ->
        get_unique_event_name(name <> " Copy")
    end
  end

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
  def list_item_groups(event),
    do: event |> Ecto.assoc(:item_groups) |> order_by([ig], ig.name) |> Repo.all()

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

  def list_relevant_items_query(location)

  def list_relevant_items_query(%Location{id: location_id}) do
    from(item in Item,
      join: item_group in assoc(item, :item_group),
      as: :item_group,
      join: movement in assoc(item, :movements),
      as: :movement,
      where:
        movement.source_location_id == ^location_id or
          movement.destination_location_id == ^location_id,
      group_by: item.id,
      order_by: item.name
    )
  end

  def list_relevant_item_groups_query(%Location{} = location) do
    relevant_items_query =
      location
      |> list_relevant_items_query
      |> Ecto.Query.exclude(:group_by)
      |> Ecto.Query.exclude(:order_by)

    from([item, item_group: item_group] in relevant_items_query,
      group_by: item_group.id,
      select: item_group,
      order_by: item_group.name
    )
  end

  def list_relevant_items(%Location{} = location, %ItemGroup{id: item_group_id}) do
    Repo.all(
      from(
        [item, item_group: item_group] in list_relevant_items_query(location),
        where: item_group.id == ^item_group_id
      )
    )
  end

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
        notify_pubsub(
          {:ok, movement},
          :created,
          "movement",
          [
            "location:#{source_location_id}",
            "location:#{destination_location_id}",
            "item:#{item_id}",
            "item_group:#{item_group_id}",
            "event:#{event_id}"
          ],
          %{event_id: event_id}
        )

      other ->
        other
    end
  end

  def create_movement_directly(attrs \\ %{}) do
    %Movement{}
    |> change_movement(attrs)
    |> Repo.insert()
    |> case do
      {:ok,
       %{
         source_location_id: source_location_id,
         destination_location_id: destination_location_id,
         item_id: item_id
       } = movement} ->
        %{event: %{id: event_id}, item_group: %{id: item_group_id}} =
          Repo.preload(movement, [:item_group, :event])

        notify_pubsub(
          {:ok, movement},
          :created,
          "movement",
          [
            "location:#{source_location_id}",
            "location:#{destination_location_id}",
            "item:#{item_id}",
            "item_group:#{item_group_id}",
            "event:#{event_id}"
          ],
          %{event_id: event_id}
        )

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
        notify_pubsub(
          {:ok, movement},
          :updated,
          "movement",
          [
            "location:#{source_location_id}",
            "location:#{destination_location_id}",
            "item:#{item_id}",
            "item_group:#{item_group_id}",
            "event:#{event_id}"
          ],
          %{event_id: event_id}
        )

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
    |> notify_pubsub(
      :deleted,
      "movement",
      [
        "location:#{source_location_id}",
        "location:#{destination_location_id}",
        "item:#{item_id}",
        "item_group:#{item_group_id}",
        "event:#{event_id}"
      ],
      %{event_id: event_id}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movement changes.

  ## Examples

      iex> change_movement(movement)
      %Ecto.Changeset{source: %Movement{}}

  """
  def change_movement(%Movement{} = movement, attrs \\ %{}),
    do: Movement.changeset(movement, attrs)

  @spec stock_query :: Ecto.Queryable.t()
  def stock_query do
    from(
      event in Event,
      join: stock_entry in assoc(event, :stock_entries),
      as: :stock_entry,
      join: l in assoc(stock_entry, :location),
      as: :location,
      join: ig in assoc(stock_entry, :item_group),
      as: :item_group,
      join: i in assoc(stock_entry, :item),
      as: :item,
      where:
        stock_entry.supply > 0 or stock_entry.consumption > 0 or stock_entry.movement_in > 0 or
          stock_entry.movement_out > 0 or i.inverse == true,
      select: stock_entry,
      order_by: l.name,
      order_by: ig.name,
      order_by: i.name
    )
  end

  @spec logistics_table_query(event :: Event.t()) :: Ecto.Queryable.t()
  def logistics_table_query(%Event{id: event_id}),
    do: from(event in stock_query(), where: event.id == ^event_id)

  @spec location_totals_by_location_query(query :: Ecto.Queryable.t(), location :: Location.t()) ::
          Ecto.Queryable.t()
  def location_totals_by_location_query(query \\ Location.Total, %Location{id: location_id}),
    do: from(total in query, where: total.location_id == ^location_id)

  @spec location_totals_by_event_query(query :: Ecto.Queryable.t(), event :: Event.t()) ::
          Ecto.Queryable.t()
  def location_totals_by_event_query(query \\ Location.Total, %Event{id: event_id}),
    do: from(total in query, where: total.event_id == ^event_id)

  @spec location_totals_by_item_query(query :: Ecto.Queryable.t(), item :: Item.t()) ::
          Ecto.Queryable.t()
  def location_totals_by_item_query(query \\ Location.Total, %Item{id: item_id}),
    do: from(total in query, where: total.item_id == ^item_id)

  @spec event_totals_by_event_query(query :: Ecto.Queryable.t(), event :: Event.t()) ::
          Ecto.Queryable.t()
  def event_totals_by_event_query(query \\ Event.Total, %Event{id: event_id}),
    do: from(total in query, where: total.event_id == ^event_id)

  @spec event_totals_by_item_query(query :: Ecto.Queryable.t(), item :: Item.t()) ::
          Ecto.Queryable.t()
  def event_totals_by_item_query(query \\ Event.Total, %Item{id: item_id}),
    do: from(total in query, where: total.item_id == ^item_id)

  @spec event_order_overview_by_event_query(query :: Ecto.Queryable.t(), event :: Event.t()) ::
          Ecto.Queryable.t()
  def event_order_overview_by_event_query(query \\ Event.OrderOverview, %Event{id: event_id}),
    do: from(order_overview in query, where: order_overview.event_id == ^event_id)

  @spec event_order_overview_by_item_query(query :: Ecto.Queryable.t(), item :: Item.t()) ::
          Ecto.Queryable.t()
  def event_order_overview_by_item_query(query \\ Event.OrderOverview, %Item{id: item_id}),
    do: from(order_overview in query, where: order_overview.item_id == ^item_id)

  @doc """
  Returns the list of stock_expectations.

  ## Examples

      iex> list_stock_expectations()
      [%StockExpectation{}, ...]

  """
  def list_stock_expectations(%Location{} = location),
    do: location |> Ecto.assoc(:stock_expectations) |> Repo.all()

  def list_stock_expectations(%Item{} = item),
    do: item |> Ecto.assoc(:stock_expectations) |> Repo.all()

  @doc """
  Gets a single stock_expectation.

  Raises `Ecto.NoResultsError` if the StockExpectation does not exist.

  ## Examples

      iex> get_stock_expectation!(123)
      %StockExpectation{}

      iex> get_stock_expectation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stock_expectation!(id), do: Repo.get!(StockExpectation, id)

  @doc """
  Creates a stock_expectation.

  ## Examples

      iex> create_stock_expectation(%{field: value})
      {:ok, %StockExpectation{}}

      iex> create_stock_expectation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stock_expectation(%Item{} = item, %Location{} = location, attrs \\ %{}) do
    %Item{event: %Event{id: event_id}, item_group: %ItemGroup{id: item_group_id}} =
      Repo.preload(item, [:item_group, :event])

    item
    |> change_new_stock_expectation(location, attrs)
    |> Repo.insert()
    |> case do
      {:ok, %StockExpectation{location_id: location_id, item_id: item_id} = stock_expectation} ->
        notify_pubsub(
          {:ok, stock_expectation},
          :created,
          "stock_expectation",
          [
            "location:#{location_id}",
            "item:#{item_id}",
            "item_group:#{item_group_id}",
            "event:#{event_id}"
          ],
          %{event_id: event_id}
        )

      other ->
        other
    end
  end

  @doc """
  Updates a stock_expectation.

  ## Examples

      iex> update_stock_expectation(stock_expectation, %{field: new_value})
      {:ok, %StockExpectation{}}

      iex> update_stock_expectation(stock_expectation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stock_expectation(%StockExpectation{} = stock_expectation, attrs) do
    %StockExpectation{event: %Event{id: event_id}, item_group: %ItemGroup{id: item_group_id}} =
      Repo.preload(stock_expectation, [:item_group, :event])

    stock_expectation
    |> change_stock_expectation(attrs)
    |> Repo.update()
    |> case do
      {:ok, %StockExpectation{location_id: location_id, item_id: item_id} = stock_expectation} ->
        notify_pubsub(
          {:ok, stock_expectation},
          :updated,
          "stock_expectation",
          [
            "location:#{location_id}",
            "item:#{item_id}",
            "item_group:#{item_group_id}",
            "event:#{event_id}"
          ],
          %{event_id: event_id}
        )

      other ->
        other
    end
  end

  def upsert_stock_expectation(
        %Item{id: item_id} = item,
        %Location{id: location_id} = location,
        attrs \\ %{}
      ) do
    StockExpectation
    |> Repo.get_by(item_id: item_id, location_id: location_id)
    |> case do
      nil ->
        create_stock_expectation(item, location, attrs)

      %StockExpectation{} = stock_expectation ->
        update_stock_expectation(stock_expectation, attrs)
    end
  end

  @doc """
  Deletes a stock_expectation.

  ## Examples

      iex> delete_stock_expectation(stock_expectation)
      {:ok, %StockExpectation{}}

      iex> delete_stock_expectation(stock_expectation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stock_expectation(
        %StockExpectation{
          item_id: item_id,
          location_id: location_id
        } = stock_expectation
      ) do
    %StockExpectation{event: %Event{id: event_id}, item_group: %ItemGroup{id: item_group_id}} =
      Repo.preload(stock_expectation, [:item_group, :event])

    stock_expectation
    |> Repo.delete()
    |> notify_pubsub(
      :deleted,
      "stock_expectation",
      [
        "location:#{location_id}",
        "item:#{item_id}",
        "item_group:#{item_group_id}",
        "event:#{event_id}"
      ],
      %{event_id: event_id}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stock_expectation changes.

  ## Examples

      iex> change_stock_expectation(stock_expectation)
      %Ecto.Changeset{source: %StockExpectation{}}

  """
  def change_stock_expectation(stock_expectation_or_changeset, attrs \\ %{})

  def change_stock_expectation(%StockExpectation{} = stock_expectation, attrs),
    do: StockExpectation.changeset(stock_expectation, attrs)

  def change_stock_expectation(%Ecto.Changeset{data: %StockExpectation{}} = changeset, attrs),
    do: StockExpectation.changeset(changeset, attrs)

  def change_new_stock_expectation(%Item{} = item, %Location{} = location, attrs \\ %{}) do
    item
    |> Ecto.build_assoc(:stock_expectations)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:location, location)
    |> change_stock_expectation(attrs)
  end
end
