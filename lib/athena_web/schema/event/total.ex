defmodule AthenaWeb.Schema.Event.Total do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Event.Total

  node object(:event_total) do
    field :amount, non_null(:integer)
    field :inserted_at, non_null(:datetime)

    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)

    is_type_of(&match?(%Total{}, &1))
  end

  connection(node_type: :event_total, non_null: true)
end
