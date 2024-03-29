defmodule Athena.Fixture do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Athena.Inventory` context.
  """

  alias Athena.Inventory
  alias Athena.Repo

  @valid_attrs %{name: "Aufgetischt SG 2020"}

  def event(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Inventory.create_event()

    event
  end

  @valid_attrs %{name: "GV Gallusplatz"}

  def location(event \\ event(), attrs \\ %{}) do
    {:ok, location} = Inventory.create_location(event, Enum.into(attrs, @valid_attrs))

    location
  end

  @valid_attrs %{name: "Bier"}

  def item_group(event \\ event(), attrs \\ %{}) do
    {:ok, item_group} = Inventory.create_item_group(event, Enum.into(attrs, @valid_attrs))

    item_group
  end

  @valid_attrs %{name: "Lager", unit: "Fass"}

  def item(item_group \\ item_group(), attrs \\ %{}) do
    {:ok, item} = Inventory.create_item(item_group, Enum.into(attrs, @valid_attrs))

    item
  end

  @valid_attrs %{amount: 1}

  def movement(item \\ item(), attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new_lazy(:destination_location_id, fn ->
        item
        |> Repo.preload(:event)
        |> Map.fetch!(:event)
        |> location()
        |> Map.fetch!(:id)
      end)
      |> Enum.into(@valid_attrs)

    {:ok, movement} = Inventory.create_movement(item, attrs)

    movement
  end

  @valid_attrs %{important_threshold: 5, warning_threshold: 3}

  def stock_expectation(item \\ item(), location \\ location(), attrs \\ %{}) do
    {:ok, stock_expectation} =
      Inventory.create_stock_expectation(item, location, Map.merge(@valid_attrs, attrs))

    stock_expectation
  end
end
