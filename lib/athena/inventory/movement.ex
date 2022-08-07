defmodule Athena.Inventory.Movement do
  @moduledoc """
  Movement Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type t :: %__MODULE__{
          amount: pos_integer(),
          event: Ecto.Schema.has_one(Event.t()),
          item: Ecto.Schema.belongs_to(Item.t()),
          item_group: Ecto.Schema.has_one(ItemGroup.t()),
          source_location: Ecto.Schema.belongs_to(Location.t() | nil),
          destination_location: Ecto.Schema.belongs_to(Location.t() | nil),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "movements" do
    field :amount, :integer

    belongs_to :source_location, Location
    belongs_to :destination_location, Location
    belongs_to :item, Item
    has_one :item_group, through: [:item, :item_group]
    has_one :event, through: [:item, :event]

    timestamps()
  end

  @doc false
  def changeset(
        movement,
        attrs,
        opts \\ %{location_required: true, validate_amount_positive: false}
      )

  def changeset(movement, attrs, %{validate_amount_positive: true} = opts) do
    movement
    |> changeset(attrs, %{opts | validate_amount_positive: false})
    |> validate_number(:amount, greater_than: 0, less_than: 1000)
  end

  def changeset(movement, attrs, %{location_required: true} = opts) do
    movement
    |> changeset(attrs, %{opts | location_required: false})
    |> validate_one_required([:source_location_id, :destination_location_id])
  end

  def changeset(movement, attrs, %{location_required: false, validate_amount_positive: false}) do
    movement
    |> cast(attrs, [:amount, :item_id, :source_location_id, :destination_location_id])
    |> fill_uuid()
    |> validate_required([:amount, :item_id])
    |> validate_number(:amount, greater_than: -1000, less_than: 1000)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:source_location_id)
    |> foreign_key_constraint(:destination_location_id)
    |> check_constraint(:amount, name: :source_stock_negative)
    |> check_constraint(:amount, name: :destination_stock_negative)
  end
end
