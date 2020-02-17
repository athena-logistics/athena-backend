defmodule Athena.Inventory.Movement do
  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Item
  alias Athena.Inventory.Location

  schema "movements" do
    field :amount, :integer

    belongs_to :source_location, Location
    belongs_to :destination_location, Location
    belongs_to :item, Item
    has_one :item_group, through: [:item, :item_group]

    timestamps()
  end

  @doc false
  def changeset(movement, attrs) do
    movement
    |> cast(attrs, [:amount, :item_id, :source_location_id, :destination_location_id])
    |> validate_required([:amount, :item_id])
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
end