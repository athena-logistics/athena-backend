defmodule Athena.InventoryTest do
  use Athena.DataCase

  alias Athena.Inventory

  import Athena.Fixture

  describe "events" do
    alias Athena.Inventory.Event

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_events/0 returns all events" do
      event = event()
      assert Inventory.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event()
      assert Inventory.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Inventory.create_event(@valid_attrs)
      assert event.name == "some name"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event()
      assert {:ok, %Event{} = event} = Inventory.update_event(event, @update_attrs)
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_event(event, @invalid_attrs)
      assert event == Inventory.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event()
      assert {:ok, %Event{}} = Inventory.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event()
      assert %Ecto.Changeset{} = Inventory.change_event(event)
    end
  end

  describe "locations" do
    alias Athena.Inventory.Location

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup do
      {:ok, event: event()}
    end

    test "list_locations/0 returns all locations", %{event: event} do
      location = location(event)
      assert Inventory.list_locations(event) == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location()
      assert Inventory.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location", %{event: event} do
      assert {:ok, %Location{} = location} = Inventory.create_location(event, @valid_attrs)
      assert location.name == "some name"
    end

    test "create_location/1 with invalid data returns error changeset", %{event: event} do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_location(event, @invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location()
      assert {:ok, %Location{} = location} = Inventory.update_location(location, @update_attrs)
      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_location(location, @invalid_attrs)
      assert location == Inventory.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location()
      assert {:ok, %Location{}} = Inventory.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location()
      assert %Ecto.Changeset{} = Inventory.change_location(location)
    end
  end

  describe "item_groups" do
    alias Athena.Inventory.ItemGroup

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup do
      {:ok, event: event()}
    end

    test "list_item_groups/0 returns all item_groups", %{event: event} do
      item_group = item_group(event)
      assert Inventory.list_item_groups(event) == [item_group]
    end

    test "get_item_group!/1 returns the item_group with given id" do
      item_group = item_group()
      assert Inventory.get_item_group!(item_group.id) == item_group
    end

    test "create_item_group/1 with valid data creates a item_group", %{event: event} do
      assert {:ok, %ItemGroup{} = item_group} = Inventory.create_item_group(event, @valid_attrs)
      assert item_group.name == "some name"
    end

    test "create_item_group/1 with invalid data returns error changeset", %{event: event} do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_item_group(event, @invalid_attrs)
    end

    test "update_item_group/2 with valid data updates the item_group" do
      item_group = item_group()

      assert {:ok, %ItemGroup{} = item_group} =
               Inventory.update_item_group(item_group, @update_attrs)

      assert item_group.name == "some updated name"
    end

    test "update_item_group/2 with invalid data returns error changeset" do
      item_group = item_group()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_item_group(item_group, @invalid_attrs)
      assert item_group == Inventory.get_item_group!(item_group.id)
    end

    test "delete_item_group/1 deletes the item_group" do
      item_group = item_group()
      assert {:ok, %ItemGroup{}} = Inventory.delete_item_group(item_group)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_item_group!(item_group.id) end
    end

    test "change_item_group/1 returns a item_group changeset" do
      item_group = item_group()
      assert %Ecto.Changeset{} = Inventory.change_item_group(item_group)
    end
  end

  describe "items" do
    alias Athena.Inventory.Item

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup do
      event = event()
      item_group = item_group()

      {:ok, event: event, item_group: item_group}
    end

    test "list_items/0 returns all items", %{item_group: item_group} do
      item = item(item_group)
      assert Inventory.list_items(item_group) == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item()
      assert Inventory.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item", %{item_group: item_group} do
      assert {:ok, %Item{} = item} = Inventory.create_item(item_group, @valid_attrs)
      assert item.name == "some name"
    end

    test "create_item/1 with invalid data returns error changeset", %{item_group: item_group} do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_item(item_group, @invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item()
      assert {:ok, %Item{} = item} = Inventory.update_item(item, @update_attrs)
      assert item.name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_item(item, @invalid_attrs)
      assert item == Inventory.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item()
      assert {:ok, %Item{}} = Inventory.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item()
      assert %Ecto.Changeset{} = Inventory.change_item(item)
    end
  end

  describe "movements" do
    alias Athena.Inventory.Movement

    @valid_attrs %{amount: 42}
    @update_attrs %{amount: 43}
    @invalid_attrs %{amount: nil}

    setup do
      event = event()
      location_a = location(event)
      location_b = location(event)

      item_group = item_group(event)
      item = item(item_group)

      {:ok,
       event: event,
       item_group: item_group,
       item: item,
       location_a: location_a,
       location_b: location_b}
    end

    test "list_movements/0 returns all movements", %{item: item} do
      movement = movement(item)
      assert Inventory.list_movements(item) == [movement]
    end

    test "get_movement!/1 returns the movement with given id" do
      movement = movement()
      assert Inventory.get_movement!(movement.id) == movement
    end

    test "create_movement/1 with valid data creates a movement", %{
      item: item,
      location_a: location
    } do
      attrs = Map.put(@valid_attrs, :destination_location_id, location.id)
      assert {:ok, %Movement{} = movement} = Inventory.create_movement(item, attrs)
      assert movement.amount == 42
    end

    test "create_movement/1 with invalid data returns error changeset", %{item: item} do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_movement(item, @invalid_attrs)
    end

    test "update_movement/2 with valid data updates the movement" do
      movement = movement()
      assert {:ok, %Movement{} = movement} = Inventory.update_movement(movement, @update_attrs)
      assert movement.amount == 43
    end

    test "update_movement/2 with invalid data returns error changeset" do
      movement = movement()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_movement(movement, @invalid_attrs)
      assert movement == Inventory.get_movement!(movement.id)
    end

    test "delete_movement/1 deletes the movement" do
      movement = movement()
      assert {:ok, %Movement{}} = Inventory.delete_movement(movement)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_movement!(movement.id) end
    end

    test "change_movement/1 returns a movement changeset" do
      movement = movement()
      assert %Ecto.Changeset{} = Inventory.change_movement(movement)
    end
  end
end
