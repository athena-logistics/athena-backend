defmodule Athena.Inventory.Event do
  @moduledoc """
  Event Model
  """

  use Athena, :model

  alias Athena.Inventory.Item
  alias Athena.Inventory.ItemGroup
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          locations: Ecto.Schema.has_many(Location.t()),
          item_groups: Ecto.Schema.has_many(ItemGroup.t()),
          items: Ecto.Schema.has_many(Item.t()),
          movements: Ecto.Schema.has_many(Movement.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "events" do
    field :name, :string

    has_many :locations, Location
    has_many :item_groups, ItemGroup
    has_many :items, through: [:item_groups, :items]
    has_many :movements, through: [:item_groups, :items, :movements]

    timestamps()
  end

  @doc false
  def changeset(event, attrs),
    do:
      event
      |> cast(attrs, [:name])
      |> validate_required([:name])
end
