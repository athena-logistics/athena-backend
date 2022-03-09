defmodule Athena.Inventory.Movement do
  @moduledoc """
  Movement Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location

  @type stock_status :: :important | :warning | :normal
  @type stock_entry :: %{
          percentage: float,
          stock: integer(),
          item: Item.t(),
          location: Location.t(),
          item_group: ItemGroup.t(),
          supply: integer(),
          consumption: integer(),
          movement_out: integer(),
          movement_in: integer(),
          stock: integer(),
          percentage: float()
        }

  @type t :: %__MODULE__{
          amount: pos_integer(),
          event: association(Event.t()),
          item: association(Item.t()),
          item_group: association(ItemGroup.t()),
          source_location: association(Location.t() | nil),
          destination_location: association(Location.t() | nil),
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
  def changeset(movement, attrs) do
    movement
    |> cast(attrs, [:amount, :item_id, :source_location_id, :destination_location_id])
    |> validate_required([:amount, :item_id])
    |> validate_number(:amount, greater_than: -100, less_than: 1000)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:source_location_id)
    |> foreign_key_constraint(:destination_location_id)
    |> validate_one_required([:source_location_id, :destination_location_id])
  end

  defp validate_one_required(changeset, [first_field | _] = fields) do
    fields
    |> Enum.map(&get_field(changeset, &1))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> add_error(changeset, first_field, "at least field is required", fields: fields)
      [_ | _] -> changeset
    end
  end

  @spec stock_status(stock_entry :: stock_entry()) :: stock_status()
  def stock_status(%{item: %Item{inverse: true}, stock: stock}) when stock > 5, do: :important
  def stock_status(%{item: %Item{inverse: true}, stock: stock}) when stock > 2, do: :warning
  def stock_status(%{item: %Item{inverse: true}}), do: :normal

  def stock_status(%{item: %Item{inverse: false}, stock: stock}) when stock in 0..1,
    do: :important

  def stock_status(%{item: %Item{inverse: false}, percentage: percentage}) when percentage >= 0.8,
    do: :important

  def stock_status(%{item: %Item{inverse: false}, percentage: percentage}) when percentage >= 0.6,
    do: :warning

  def stock_status(%{item: %Item{inverse: false}}), do: :normal
end
