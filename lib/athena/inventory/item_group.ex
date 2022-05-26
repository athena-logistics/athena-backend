defmodule Athena.Inventory.ItemGroup do
  @moduledoc """
  Item Group Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry

  @type t :: %__MODULE__{
          name: String.t(),
          event: Ecto.Schema.belongs_to(Event.t()),
          items: Ecto.Schema.has_many(Item.t()),
          movements: Ecto.Schema.has_many(Movement.t()),
          stock_entries: Ecto.Schema.has_many(StockEntry.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "item_groups" do
    field :name, :string

    belongs_to :event, Event
    has_many :items, Item
    has_many :movements, through: [:items, :movements]
    has_many :stock_entries, StockEntry

    timestamps()
  end

  @doc false
  def changeset(item_group, attrs),
    do:
      item_group
      |> cast(attrs, [:name, :event_id])
      |> validate_required([:name, :event_id])
      |> foreign_key_constraint(:event_id)
end
