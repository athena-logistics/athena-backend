defmodule AthenaWeb.Schema.Movement do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Movement

  interface :movement do
    field :id, non_null(:id)
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)
    field :event, non_null(:event)
    field :item_group, non_null(:item_group)
    field :item, non_null(:item)

    interface :node
  end

  connection(node_type: :movement, non_null: true)

  node object(:supply) do
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :destination_location, non_null(:location), resolve: dataloader(RepoDataLoader)

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(
      &match?(
        %Movement{source_location_id: nil, destination_location_id: destination_location_id}
        when is_binary(destination_location_id),
        &1
      )
    )

    interface :resource
    interface :movement
  end

  connection(node_type: :supply, non_null: true)

  node object(:consumption) do
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :source_location, non_null(:location), resolve: dataloader(RepoDataLoader)

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(
      &match?(
        %Movement{destination_location_id: nil, source_location_id: source_location_id}
        when is_binary(source_location_id),
        &1
      )
    )

    interface :resource
    interface :movement
  end

  connection(node_type: :consumption, non_null: true)

  node object(:transfer) do
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :source_location, non_null(:location), resolve: dataloader(RepoDataLoader)
    field :destination_location, non_null(:location), resolve: dataloader(RepoDataLoader)

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(
      &match?(
        %Movement{
          source_location_id: source_location_id,
          destination_location_id: destination_location_id
        }
        when is_binary(destination_location_id) and is_binary(source_location_id),
        &1
      )
    )

    interface :resource
    interface :movement
  end

  connection(node_type: :transfer, non_null: true)
end
