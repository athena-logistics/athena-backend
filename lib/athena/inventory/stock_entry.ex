defmodule Athena.Inventory.StockEntry do
  @moduledoc """
  StockEntry Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type status :: :important | :warning | :normal

  @type t :: %__MODULE__{
          supply: non_neg_integer(),
          consumption: non_neg_integer(),
          movement_in: non_neg_integer(),
          movement_out: non_neg_integer(),
          stock: integer(),
          status: status(),
          missing_count: non_neg_integer(),
          location: Ecto.Schema.belongs_to(Location.t()),
          item_group: Ecto.Schema.belongs_to(ItemGroup.t()),
          item: Ecto.Schema.belongs_to(Item.t()),
          event: Ecto.Schema.belongs_to(Event.t())
        }

  @primary_key false
  schema "stock_entries" do
    field :supply, :integer
    field :consumption, :integer
    field :movement_in, :integer
    field :movement_out, :integer
    field :stock, :integer
    field :status, Ecto.Enum, values: [:normal, :warning, :important]
    field :missing_count, :integer

    belongs_to :item_group, ItemGroup
    belongs_to :location, Location, primary_key: true
    belongs_to :item, Item, primary_key: true
    belongs_to :event, Event
  end

  @spec percentage(entry :: t()) :: float() | nil
  def percentage(%__MODULE__{movement_in: 0, supply: 0}), do: nil

  def percentage(%__MODULE__{
        movement_in: movement_in,
        supply: supply,
        consumption: consumption,
        movement_out: movement_out
      }),
      do: (consumption + movement_out) / (supply + movement_in)
end
