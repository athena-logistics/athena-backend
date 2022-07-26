defmodule Athena.Inventory.Event.Total do
  @moduledoc """
  Event Total Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup

  @type t :: %__MODULE__{
          amount: non_neg_integer(),
          item_group: Ecto.Schema.has_one(ItemGroup.t()),
          item: Ecto.Schema.belongs_to(Item.t()),
          item_id: Ecto.UUID.t(),
          event: Ecto.Schema.belongs_to(Event.t()),
          event_id: Ecto.UUID.t(),
          inserted_at: DateTime.t()
        }

  @primary_key false
  schema "location_totals" do
    field :amount, :integer

    belongs_to :item, Item
    has_one :item_group, through: [:item, :item_group]
    belongs_to :event, Event

    timestamps(updated_at: false)
  end
end
