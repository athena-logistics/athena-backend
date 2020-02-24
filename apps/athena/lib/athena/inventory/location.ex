defmodule Athena.Inventory.Location do
  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Item
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          event: association(Event.t()),
          item_groups: association([ItemGroup.t()]),
          items: association([Item.t()]),
          movements_in: association([Movement.t()]),
          movements_out: association([Movement.t()]),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "locations" do
    field :name, :string

    belongs_to :event, Event
    has_many :item_groups, through: [:event, :item_groups]
    has_many :items, through: [:event, :item_groups, :items]
    has_many :movements_in, Movement, foreign_key: :destination_location_id
    has_many :movements_out, Movement, foreign_key: :source_location_id

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
