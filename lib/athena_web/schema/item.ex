defmodule AthenaWeb.Schema.Item do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Item
  alias AthenaWeb.Schema.Event.Total.Resolver, as: EventTotalResolver
  alias AthenaWeb.Schema.Location.Total.Resolver, as: LocationTotalResolver

  node object(:item) do
    field :name, non_null(:string)
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :inverse, non_null(:boolean)
    field :unit, non_null(:string)

    connection field :movements, node_type: :movement do
      resolve many_dataloader()
    end

    connection field :stock, node_type: :stock_entry do
      resolve &Resolver.stock/3
    end

    @desc "Get a timeline of stock of this item per location (granularity: 15 minutes)"
    connection field :location_totals, node_type: :location_total do
      arg :filters, :location_total_filter, default_value: %{}

      middleware Absinthe.Relay.Node.ParseIDs, filters: [location_id_equals: :location]

      resolve many_dataloader(&LocationTotalResolver.query_filter/4)
    end

    @desc "Get a timeline of stock of this item in the whole event (granularity: 15 minutes)"
    connection field :event_totals, node_type: :event_total do
      arg :filters, :event_total_filter, default_value: %{}

      resolve many_dataloader(&EventTotalResolver.query_filter/4)
    end

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(&match?(%Item{}, &1))

    interface :resource
  end

  connection(node_type: :item, non_null: true)
end
