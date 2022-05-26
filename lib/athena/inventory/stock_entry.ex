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

  @spec status(entry :: t()) :: status()
  def status(%__MODULE__{stock: stock, item: %Item{inverse: inverse}} = entry),
    do: status(inverse, percentage(entry), stock)

  defp status(inverse, percentage, stock)
  defp status(_inverse, nil, 0), do: :normal
  defp status(true, _percentage, stock) when stock > 5, do: :important
  defp status(true, _percentage, stock) when stock > 2, do: :warning
  defp status(true, _percentage, _stock), do: :normal
  defp status(false, _percentage, stock) when stock in 0..1, do: :important
  defp status(false, percentage, _stock) when percentage >= 0.8, do: :important
  defp status(false, percentage, _stock) when percentage >= 0.6, do: :warning
  defp status(false, _percentage, _stock), do: :normal
end
