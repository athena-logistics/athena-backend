defmodule Athena.Inventory.Location do
  @moduledoc """
  Location Model
  """

  use Athena, :model

  alias Athena.Inventory.Event
  alias Athena.Inventory.Movement

  @type t :: %__MODULE__{
          name: String.t(),
          event: association(Event.t()),
          movements_in: association([Movement.t()]),
          movements_out: association([Movement.t()]),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "locations" do
    field :name, :string

    belongs_to :event, Event
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
