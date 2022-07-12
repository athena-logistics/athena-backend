defmodule Athena.Inventory.Location.Total do
  @moduledoc """
  Location Total Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type t :: %__MODULE__{
          amount: non_neg_integer(),
          location: Ecto.Schema.belongs_to(Location.t()),
          location_id: Ecto.UUID.t(),
          item_group: Ecto.Schema.has_one(ItemGroup.t()),
          item: Ecto.Schema.belongs_to(Item.t()),
          item_id: Ecto.UUID.t(),
          event: Ecto.Schema.has_one(Event.t()),
          inserted_at: DateTime.t()
        }

  @primary_key false
  schema "location_totals" do
    field :amount, :integer

    belongs_to :location, Location
    belongs_to :item, Item
    has_one :item_group, through: [:item, :item_group]
    has_one :event, through: [:location, :event]

    timestamps(updated_at: false)
  end
end
