defmodule AthenaWeb.Schema.StockEntry do
  @moduledoc false

  use AthenaWeb, :subschema

  enum :stock_entry_status do
    value :important
    value :warning
    value :normal
  end

  object :stock_entry do
    field :item, non_null(:item)
    field :item_group, non_null(:item_group)
    field :location, non_null(:location)
    field :consumption, non_null(:integer)
    field :movement_in, non_null(:integer)
    field :movement_out, non_null(:integer)
    field :stock, non_null(:integer)
    field :status, non_null(:stock_entry_status), resolve: &Resolver.status/3
    field :supply, non_null(:integer)
  end

  connection(node_type: :stock_entry, non_null: true)
end
