defmodule Athena.InventoryTest do
  use Athena.DataCase

  import Athena.Fixture

  alias Athena.Inventory
  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry
  alias Athena.Inventory.StockExpectation

  describe "events" do
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

    test "duplicate_event/2 duplicates all models except movements" do
      event = event()
      location = location(event)
      item_group = item_group(event)
      item = item(item_group)
      stock_expectation(item, location)

      assert {:ok, %Event{} = new_event} = Inventory.duplicate_event(event, "new name")

      assert %Event{
               locations: [%Location{stock_expectations: [%StockExpectation{}]}],
               item_groups: [%ItemGroup{items: [%Item{}]}]
             } =
               Repo.preload(new_event,
                 locations: [stock_expectations: []],
                 item_groups: [items: []]
               )
    end
  end

  describe "locations" do
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
    @valid_attrs %{name: "some name", unit: "Cask", inverse: false}
    @update_attrs %{name: "some updated name", unit: "Box", inverse: true}
    @invalid_attrs %{name: nil, unit: nil, inverse: nil}

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
      assert item.unit == "Cask"
      refute item.inverse
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

    test "get_item_consumption/1 gives correct consumption", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: location_a.id, amount: 1, destination_location_id: nil})

      movement(item, %{
        source_location_id: location_a.id,
        destination_location_id: location_b.id,
        amount: 1
      })

      assert 1 == Inventory.get_item_consumption(item)
    end

    test "get_item_consumption/1 gives correct consumption for 0", %{
      item_group: item_group
    } do
      item = item(item_group)

      assert 0 == Inventory.get_item_consumption(item)
    end

    test "get_item_consumption/2 gives correct consumption", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: location_a.id, amount: 1, destination_location_id: nil})

      movement(item, %{source_location_id: location_b.id, amount: 1, destination_location_id: nil})

      assert 1 == Inventory.get_item_consumption(item, location_a)
    end

    test "get_item_supply/1 gives correct supply", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: nil, amount: 1, destination_location_id: location_a.id})

      movement(item, %{
        source_location_id: location_b.id,
        destination_location_id: location_a.id,
        amount: 1
      })

      assert 1 == Inventory.get_item_supply(item)
    end

    test "get_item_supply/1 gives correct supply for 0", %{
      item_group: item_group
    } do
      item = item(item_group)

      assert 0 == Inventory.get_item_supply(item)
    end

    test "get_item_supply/2 gives correct supply", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: nil, amount: 1, destination_location_id: location_a.id})

      movement(item, %{source_location_id: nil, amount: 1, destination_location_id: location_b.id})

      assert 1 == Inventory.get_item_supply(item, location_a)
    end

    test "get_item_relocations/1 gives correct deliveries", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{
        source_location_id: location_b.id,
        destination_location_id: location_a.id,
        amount: 1
      })

      movement(item, %{source_location_id: nil, amount: 1, destination_location_id: location_a.id})

      assert 1 == Inventory.get_item_relocations(item)
    end

    test "get_item_relocations/1 gives correct deliveries for 0", %{
      item_group: item_group
    } do
      item = item(item_group)

      assert 0 == Inventory.get_item_relocations(item)
    end

    test "get_item_relocations_out/2 gives correct deliveries", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{
        source_location_id: location_a.id,
        amount: 1,
        destination_location_id: location_b.id
      })

      movement(item, %{
        source_location_id: location_b.id,
        amount: 1,
        destination_location_id: location_a.id
      })

      assert 1 == Inventory.get_item_relocations_out(item, location_a)
    end

    test "get_item_relocations_in/2 gives correct deliveries", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{
        source_location_id: location_a.id,
        amount: 1,
        destination_location_id: location_b.id
      })

      movement(item, %{
        source_location_id: location_b.id,
        amount: 1,
        destination_location_id: location_a.id
      })

      assert 1 == Inventory.get_item_relocations_out(item, location_a)
    end

    test "get_item_stock/1 gives correct stock", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: nil, amount: 3, destination_location_id: location_a.id})

      movement(item, %{
        source_location_id: location_a.id,
        amount: 1,
        destination_location_id: location_b.id
      })

      movement(item, %{source_location_id: location_a.id, amount: 1, destination_location_id: nil})

      assert 2 == Inventory.get_item_stock(item)
    end

    test "get_item_stock/1 gives correct stock for 0", %{
      item_group: item_group
    } do
      item = item(item_group)

      assert 0 == Inventory.get_item_stock(item)
    end

    test "get_item_stock/2 gives correct stock", %{
      event: event,
      item_group: item_group
    } do
      item = item(item_group)

      location_a = location(event)
      location_b = location(event)

      movement(item, %{source_location_id: nil, amount: 3, destination_location_id: location_a.id})

      movement(item, %{
        source_location_id: location_a.id,
        amount: 1,
        destination_location_id: location_b.id
      })

      movement(item, %{source_location_id: location_a.id, amount: 1, destination_location_id: nil})

      assert 1 == Inventory.get_item_stock(item, location_a)
    end
  end

  describe "movements" do
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

  describe "stock_expectations" do
    @valid_attrs %{important_threshold: 5, warning_threshold: 3}
    @update_attrs %{important_threshold: 4}
    @invalid_attrs %{important_threshold: -3}

    setup do
      event = event()
      location = location(event)

      item_group = item_group(event)
      item = item(item_group)

      {:ok, event: event, item_group: item_group, item: item, location: location}
    end

    test "list_stock_expectations/0 returns all stock_expectations", %{item: item} do
      stock_expectation = stock_expectation(item)

      assert item |> Inventory.list_stock_expectations() |> Repo.preload(:location) == [
               stock_expectation
             ]
    end

    test "get_stock_expectation!/1 returns the stock_expectation with given id" do
      stock_expectation = stock_expectation()

      assert stock_expectation.id |> Inventory.get_stock_expectation!() |> Repo.preload(:location) ==
               stock_expectation
    end

    test "create_stock_expectation/1 with valid data creates a stock_expectation", %{
      item: item,
      location: location
    } do
      assert {:ok, %StockExpectation{} = stock_expectation} =
               Inventory.create_stock_expectation(item, location, @valid_attrs)

      assert stock_expectation.important_threshold == 5
    end

    test "create_stock_expectation/1 with invalid data returns error changeset", %{
      item: item,
      location: location
    } do
      assert {:error, %Ecto.Changeset{}} =
               Inventory.create_stock_expectation(item, location, @invalid_attrs)
    end

    test "update_stock_expectation/2 with valid data updates the stock_expectation" do
      stock_expectation = stock_expectation()

      assert {:ok, %StockExpectation{} = stock_expectation} =
               Inventory.update_stock_expectation(stock_expectation, @update_attrs)

      assert stock_expectation.important_threshold == 4
    end

    test "update_stock_expectation/2 with invalid data returns error changeset" do
      stock_expectation = stock_expectation()

      assert {:error, %Ecto.Changeset{}} =
               Inventory.update_stock_expectation(stock_expectation, @invalid_attrs)

      assert stock_expectation ==
               stock_expectation.id
               |> Inventory.get_stock_expectation!()
               |> Repo.preload(:location)
    end

    test "delete_stock_expectation/1 deletes the stock_expectation" do
      stock_expectation = stock_expectation()
      assert {:ok, %StockExpectation{}} = Inventory.delete_stock_expectation(stock_expectation)

      assert_raise Ecto.NoResultsError, fn ->
        Inventory.get_stock_expectation!(stock_expectation.id)
      end
    end

    test "change_stock_expectation/1 returns a stock_expectation changeset" do
      stock_expectation = stock_expectation()
      assert %Ecto.Changeset{} = Inventory.change_stock_expectation(stock_expectation)
    end

    test "sets status correctly in stock_entry", %{item: item, location: location} do
      stock_expectation(item, location, %{important_threshold: 3, warning_threshold: 5})

      movement(item, %{source_location_id: nil, destination_location_id: location.id, amount: 6})

      assert %StockEntry{status: :normal, missing_count: 0} =
               Repo.get_by(StockEntry, item_id: item.id)

      movement(item, %{source_location_id: location.id, destination_location_id: nil, amount: 2})

      assert %StockEntry{status: :warning, missing_count: 1} =
               Repo.get_by(StockEntry, item_id: item.id)

      movement(item, %{source_location_id: location.id, destination_location_id: nil, amount: 2})

      assert %StockEntry{status: :important, missing_count: 3} =
               Repo.get_by(StockEntry, item_id: item.id)
    end
  end
end
