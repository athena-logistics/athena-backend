defmodule Athena.Inventory.Item do
  @moduledoc """
  Item Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry

  @type t :: %__MODULE__{
          name: String.t(),
          unit: String.t(),
          inverse: boolean,
          item_group: Ecto.Schema.belongs_to(ItemGroup.t()),
          event: Ecto.Schema.has_one(Event.t()),
          stock_entries: Ecto.Schema.has_many(StockEntry.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "items" do
    field :name, :string
    field :unit, :string
    field :inverse, :boolean, default: false

    belongs_to :item_group, ItemGroup
    has_one :event, through: [:item_group, :event]
    has_many :movements, Movement
    has_many :stock_entries, StockEntry

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :unit, :inverse, :item_group_id])
    |> validate_required([:name, :unit, :inverse, :item_group_id])
    |> foreign_key_constraint(:item_group_id)
  end
end
