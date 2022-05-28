defmodule Athena.Inventory.Event do
  @moduledoc """
  Event Model
  """

  use Athena, :model

  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry

  @type t :: %__MODULE__{
          name: String.t(),
          locations: Ecto.Schema.has_many(Location.t()),
          item_groups: Ecto.Schema.has_many(ItemGroup.t()),
          items: Ecto.Schema.has_many(Item.t()),
          movements: Ecto.Schema.has_many(Movement.t()),
          stock_entries: Ecto.Schema.has_many(StockEntry.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "events" do
    field :name, :string

    has_many :locations, Location, preload_order: [asc: :name]
    has_many :item_groups, ItemGroup, preload_order: [asc: :name]
    has_many :items, through: [:item_groups, :items], preload_order: [asc: :name]

    has_many :movements,
      through: [:item_groups, :items, :movements],
      preload_order: [asc: :inserted_at]

    has_many :stock_entries, StockEntry, preload_order: [asc: :item_id, asc: :location_id]

    timestamps()
  end

  @doc false
  def changeset(event, attrs),
    do:
      event
      |> cast(attrs, [:name])
      |> fill_uuid()
      |> validate_required([:name])
end
