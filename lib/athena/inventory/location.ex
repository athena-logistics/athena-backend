defmodule Athena.Inventory.Location do
  @moduledoc """
  Location Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry

  @type t :: %__MODULE__{
          name: String.t(),
          event: Ecto.Schema.belongs_to(Event.t()),
          movements_in: Ecto.Schema.has_many([Movement.t()]),
          movements_out: Ecto.Schema.has_many([Movement.t()]),
          stock_entries: Ecto.Schema.has_many(StockEntry.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "locations" do
    field :name, :string

    belongs_to :event, Event

    has_many :movements_in, Movement,
      foreign_key: :destination_location_id,
      preload_order: [asc: :inserted_at]

    has_many :movements_out, Movement,
      foreign_key: :source_location_id,
      preload_order: [asc: :inserted_at]

    has_many :stock_entries, StockEntry, preload_order: [asc: :item_id]

    timestamps()
  end

  @doc false
  def changeset(location, attrs),
    do:
      location
      |> cast(attrs, [:name, :event_id])
      |> fill_uuid()
      |> validate_required([:name, :event_id])
      |> foreign_key_constraint(:event_id)
end
