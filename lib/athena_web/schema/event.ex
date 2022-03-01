defmodule AthenaWeb.Schema.Event do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Event

  node object(:event) do
    field :name, non_null(:string)

    # connection field :locations, node_type: :location
    # connection field :item_groups, node_type: :item_group
    # connection field :items, node_type: :item

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
