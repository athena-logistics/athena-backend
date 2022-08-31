defmodule AthenaWeb.Schema.Location.Total do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Event.Total

  object :location_total do
    field :amount, non_null(:integer)
    field :delta, non_null(:integer)
    field :date, non_null(:datetime)

    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :location, non_null(:location), resolve: dataloader(RepoDataLoader)
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)

    is_type_of(&match?(%Total{}, &1))
  end

  input_object :location_total_filter do
    field :location_id_equals, :id
    field :include_zero_deltas, :boolean
    field :date_from, :datetime
    field :date_to, :datetime
  end

  connection(node_type: :location_total, non_null: true)
end
