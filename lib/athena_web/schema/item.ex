defmodule AthenaWeb.Schema.Item do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.Item

  node object(:item) do
    field :name, non_null(:string)
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :inverse, non_null(:boolean)

    connection field :movements, node_type: :movement do
      resolve many_dataloader()
    end

    connection field :stock, node_type: :stock_entry do
      resolve &Resolver.stock/3
    end

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(&match?(%Item{}, &1))

    interface :resource
  end

  connection(node_type: :item, non_null: true)
end
