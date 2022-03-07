defmodule Athena.Inventory.ItemGroup do
  @moduledoc """
  Item Group Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Item
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          event: Ecto.Schema.belongs_to(Event.t()),
          items: Ecto.Schema.has_many(Item.t()),
          movements: Ecto.Schema.has_many(Movement.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "item_groups" do
    field :name, :string

    belongs_to :event, Event
    has_many :items, Item
    has_many :movements, through: [:items, :movements]

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
