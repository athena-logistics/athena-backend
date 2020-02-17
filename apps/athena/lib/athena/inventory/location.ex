defmodule Athena.Inventory.Location do
  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Item

  @type t :: %__MODULE__{
          name: String.t(),
          event: association(Event.t()),
          item_groups: association([ItemGroup.t()]),
          items: association([Item.t()]),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "locations" do
    field :name, :string

    belongs_to :event, Event
    has_many :item_groups, through: [:event, :item_groups]
    has_many :items, through: [:event, :item_groups, :items]

    timestamps()
  end

  @doc false
  def changeset(location, attrs),
    do:
      location
      |> cast(attrs, [:name, :event_id])
      |> validate_required([:name, :event_id])
      |> foreign_key_constraint(:event_id)
end
