defmodule AthenaWeb.Schema.Event do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Event
  alias AthenaWeb.Schema.Event.Total.Resolver, as: EventTotalResolver
  alias AthenaWeb.Schema.Location.Total.Resolver, as: LocationTotalResolver

  node object(:event) do
    field :name, non_null(:string)

    connection field :locations, node_type: :location do
      resolve many_dataloader()
    end

    connection field :item_groups, node_type: :item_group do
      resolve many_dataloader()
    end

    connection field :items, node_type: :item do
      resolve many_dataloader()
    end

    connection field :movements, node_type: :movement do
      resolve many_dataloader()
    end

    @desc "Get a timeline of stock for this event (granularity: 15 minutes)"
    connection field :totals, node_type: :event_total do
      arg :filters, :event_total_filter, default_value: %{}

      resolve many_dataloader(&EventTotalResolver.query_filter/4)
    end

    @desc "Get a timeline of stock for this event per location (granularity: 15 minutes)"
    connection field :location_totals, node_type: :location_total do
      arg :filters, :location_total_filter, default_value: %{}

      resolve many_dataloader(&LocationTotalResolver.query_filter/4)
    end

    connection field :stock, node_type: :stock_entry do
      resolve &Resolver.stock/3
    end

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(&match?(%Event{}, &1))

    interface :resource
  end

  connection(node_type: :event, non_null: true)

  object :event_queries do
    @desc "Get Event By ID"
    field :event, :event do
      arg :id, non_null(:id)

      resolve(&Resolver.event/3)
    end
  end
end
