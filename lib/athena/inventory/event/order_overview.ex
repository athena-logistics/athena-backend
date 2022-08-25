defmodule Athena.Inventory.Event.OrderOverview do
  @moduledoc """
  Event Order Overview Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type t :: %__MODULE__{
          amount: non_neg_integer(),
          date: Date.t() | nil,
          type: :supply | :consumption,
          location: Ecto.Schema.belongs_to(Location.t() | nil),
          location_id: Ecto.UUID.t() | nil,
          item: Ecto.Schema.belongs_to(Item.t()),
          item_id: Ecto.UUID.t(),
          item_group: Ecto.Schema.belongs_to(ItemGroup.t()),
          item_group_id: Ecto.UUID.t(),
          event: Ecto.Schema.belongs_to(Event.t()),
          event_id: Ecto.UUID.t()
        }

  @primary_key false
  schema "event_order_overview" do
    field :amount, :integer
    field :date, :date
    field :type, Ecto.Enum, values: [:supply, :consumption]

    belongs_to :location, Location
    belongs_to :item, Item
    belongs_to :item_group, ItemGroup
    belongs_to :event, Event
  end
end
