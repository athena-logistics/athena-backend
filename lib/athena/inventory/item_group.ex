defmodule Athena.Inventory.ItemGroup do
  @moduledoc """
  Item Group Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.Location

  @type t :: %__MODULE__{
          name: String.t(),
          event: association(Event.t()),
          location: association(Location.t()),
          items: association([Item.t()]),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "item_groups" do
    field :name, :string

    belongs_to :event, Event
    has_one :location, through: [:event, :location]
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(item_group, attrs),
    do:
      item_group
      |> cast(attrs, [:name, :event_id])
      |> validate_required([:name, :event_id])
      |> foreign_key_constraint(:event_id)
end
