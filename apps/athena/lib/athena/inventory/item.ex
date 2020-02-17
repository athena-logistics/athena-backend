defmodule Athena.Inventory.Item do
  use Athena, :model

  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Event
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          item_group: association(ItemGroup.t()),
          event: association(Event.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "items" do
    field :name, :string

    belongs_to :item_group, ItemGroup
    has_one :event, through: [:item_group, :event]
    has_many :movements, Movement

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :item_group_id])
    |> validate_required([:name, :item_group_id])
    |> foreign_key_constraint(:item_group_id)
  end
end
