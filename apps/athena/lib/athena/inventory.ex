defmodule Athena.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Athena.Repo

  alias Athena.Inventory.Event

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

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event), do: Repo.delete(event)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}), do: Event.changeset(event, attrs)

  alias Athena.Inventory.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations(event), do: event |> Ecto.assoc(:locations) |> Repo.all()

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
  def create_location(event, attrs \\ %{}),
    do:
      event
      |> Ecto.build_assoc(:locations)
      |> change_location(attrs)
      |> Repo.insert()

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs),
    do:
      location
      |> change_location(attrs)
      |> Repo.update()

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location), do: Repo.delete(location)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}),
    do: Location.changeset(location, attrs)

  alias Athena.Inventory.ItemGroup

  @doc """
  Returns the list of item_groups.

  ## Examples

      iex> list_item_groups()
      [%ItemGroup{}, ...]

  """
  def list_item_groups(event), do: event |> Ecto.assoc(:item_groups) |> Repo.all()

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
  def create_item_group(event, attrs \\ %{}),
    do:
      event
      |> Ecto.build_assoc(:item_groups)
      |> change_item_group(attrs)
      |> Repo.insert()

  @doc """
  Updates a item_group.

  ## Examples

      iex> update_item_group(item_group, %{field: new_value})
      {:ok, %ItemGroup{}}

      iex> update_item_group(item_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_group(%ItemGroup{} = item_group, attrs),
    do:
      item_group
      |> change_item_group(attrs)
      |> Repo.update()

  @doc """
  Deletes a item_group.

  ## Examples

      iex> delete_item_group(item_group)
      {:ok, %ItemGroup{}}

      iex> delete_item_group(item_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_group(%ItemGroup{} = item_group), do: Repo.delete(item_group)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_group changes.

  ## Examples

      iex> change_item_group(item_group)
      %Ecto.Changeset{source: %ItemGroup{}}

  """
  def change_item_group(%ItemGroup{} = item_group, attrs \\ %{}),
    do: ItemGroup.changeset(item_group, attrs)

  alias Athena.Inventory.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(%ItemGroup{} = item_group), do: item_group |> Ecto.assoc(:items) |> Repo.all()
  def list_items(%Event{} = event), do: event |> Ecto.assoc(:items) |> Repo.all()

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

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(item_group, attrs \\ %{}),
    do:
      item_group
      |> Ecto.build_assoc(:items)
      |> change_item(attrs)
      |> Repo.insert()

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs),
    do:
      item
      |> change_item(attrs)
      |> Repo.update()

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item), do: Repo.delete(item)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}), do: Item.changeset(item, attrs)

  alias Athena.Inventory.Movement

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
  def create_movement(item, attrs \\ %{}),
    do:
      item
      |> Ecto.build_assoc(:movements)
      |> change_movement(attrs)
      |> Repo.insert()

  @doc """
  Updates a movement.

  ## Examples

      iex> update_movement(movement, %{field: new_value})
      {:ok, %Movement{}}

      iex> update_movement(movement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_movement(%Movement{} = movement, attrs),
    do:
      movement
      |> change_movement(attrs)
      |> Repo.update()

  @doc """
  Deletes a movement.

  ## Examples

      iex> delete_movement(movement)
      {:ok, %Movement{}}

      iex> delete_movement(movement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_movement(%Movement{} = movement), do: Repo.delete(movement)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movement changes.

  ## Examples

      iex> change_movement(movement)
      %Ecto.Changeset{source: %Movement{}}

  """
  def change_movement(%Movement{} = movement, attrs \\ %{}),
    do: Movement.changeset(movement, attrs)
end
