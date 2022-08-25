defmodule Athena.Inventory.Item do
  @moduledoc """
  Item Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry

  @type t :: %__MODULE__{
          name: String.t(),
          unit: String.t(),
          inverse: boolean,
          item_group: Ecto.Schema.belongs_to(ItemGroup.t()),
          event: Ecto.Schema.has_one(Event.t()),
          stock_entries: Ecto.Schema.has_many(StockEntry.t()),
          location_totals: Ecto.Schema.has_many(Location.Total.t()),
          event_totals: Ecto.Schema.has_many(Event.Total.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "items" do
    field :name, :string
    field :unit, :string
    field :inverse, :boolean, default: false

    belongs_to :item_group, ItemGroup
    has_one :event, through: [:item_group, :event]
    has_many :movements, Movement, preload_order: [asc: :inserted_at]
    has_many :stock_entries, StockEntry, preload_order: [asc: :location_id]
    has_many :location_totals, Location.Total, preload_order: [asc: :inserted_at]
    has_many :event_totals, Event.Total, preload_order: [asc: :inserted_at]

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :unit, :inverse, :item_group_id])
    |> fill_uuid()
    |> validate_required([:name, :unit, :inverse, :item_group_id])
    |> foreign_key_constraint(:item_group_id)
  end
end
