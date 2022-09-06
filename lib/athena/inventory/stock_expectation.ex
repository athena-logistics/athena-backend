defmodule Athena.Inventory.StockExpectation do
  @moduledoc """
  StockExpectation Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          warning_threshold: non_neg_integer(),
          important_threshold: non_neg_integer(),
          item: Ecto.Schema.belongs_to(Item.t()),
          item_id: Ecto.UUID.t(),
          item_group: Ecto.Schema.has_one(ItemGroup.t()),
          location: Ecto.Schema.belongs_to(Location.t()),
          location_id: Ecto.UUID.t(),
          event: Ecto.Schema.has_one(Event.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "stock_expectations" do
    field :warning_threshold, :integer
    field :important_threshold, :integer

    belongs_to :item, Item
    belongs_to :location, Location
    has_one :item_group, through: [:item, :item_group]
    has_one :event, through: [:location, :event]

    timestamps()
  end

  @doc false
  def changeset(stock_expectation, attrs) do
    stock_expectation
    |> cast(attrs, [:id, :warning_threshold, :important_threshold])
    |> fill_uuid()
    |> validate_required([:warning_threshold, :important_threshold])
    |> validate_number(:warning_threshold, greater_than_or_equal_to: 0)
    |> validate_number(:important_threshold, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:location_id)
    |> unique_constraint([:item_id, :location_id])
  end
end
