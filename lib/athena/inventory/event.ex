defmodule Athena.Inventory.Event do
  use Athena, :model

  alias Athena.Inventory.Location
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Item

  @type t :: %__MODULE__{
          name: String.t(),
          locations: association([Location.t()]),
          item_groups: association([ItemGroup.t()]),
          items: association([Item.t()]),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "events" do
    field :name, :string

    has_many :locations, Location
    has_many :item_groups, ItemGroup
    has_many :items, through: [:item_groups, :items]

    timestamps()
  end

  @doc false
  def changeset(event, attrs),
    do:
      event
      |> cast(attrs, [:name])
      |> validate_required([:name])
end
