defmodule Athena.Inventory.Item do
  @moduledoc """
  Item Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          unit: String.t(),
          inverse: boolean,
          item_group: association(ItemGroup.t()),
          event: association(Event.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "items" do
    field :name, :string
    field :unit, :string
    field :inverse, :boolean, default: false

    belongs_to :item_group, ItemGroup
    has_one :event, through: [:item_group, :event]
    has_many :movements, Movement

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :unit, :inverse, :item_group_id])
    |> validate_required([:name, :unit, :inverse, :item_group_id])
    |> foreign_key_constraint(:item_group_id)
  end
end
