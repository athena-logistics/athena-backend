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

    field :location, non_null(:location),
      resolve: dataloader(RepoDataLoader, :destination_location)

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
    field :location, non_null(:location), resolve: dataloader(RepoDataLoader, :source_location)

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

  node object(:relocation) do
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

  connection(node_type: :relocation, non_null: true)

  object :movement_mutations do
    payload field :supply do
      input do
        field :amount, non_null(:integer), default_value: 1
        field :item_id, non_null(:id)
        field :location_id, non_null(:id)
      end

      output do
        payload_fields(:supply)
      end

      middleware Absinthe.Relay.Node.ParseIDs, item_id: :item, location_id: :location

      resolve &Resolver.supply/3

      middleware(&build_payload/2)
    end

    payload field :consume do
      input do
        field :amount, non_null(:integer), default_value: 1
        field :item_id, non_null(:id)
        field :location_id, non_null(:id)
      end

      output do
        payload_fields(:consumption)
      end

      middleware Absinthe.Relay.Node.ParseIDs, item_id: :item, location_id: :location

      resolve &Resolver.consume/3

      middleware(&build_payload/2)
    end

    payload field :relocate do
      input do
        field :amount, non_null(:integer), default_value: 1
        field :item_id, non_null(:id)
        field :source_location_id, non_null(:id)
        field :destination_location_id, non_null(:id)
      end

      output do
        payload_fields(:relocation)
      end

      middleware Absinthe.Relay.Node.ParseIDs,
        item_id: :item,
        source_location_id: :location,
        destination_location_id: :location

      resolve &Resolver.relocate/3

      middleware(&build_payload/2)
    end
  end

  object :location_subscriptions do
    field :movement_created, :movement do
      arg :event_id, :id
      arg :location_id, :id

      config(&SubscriptionConfig.created/2)
    end
  end
end
