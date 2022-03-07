defmodule AthenaWeb.Schema.ItemGroup do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.ItemGroup

  node object(:item_group) do
    field :name, non_null(:string)
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)

    connection field :items, node_type: :item do
      resolve many_dataloader()
    end

    connection field :movements, node_type: :movement do
      resolve many_dataloader()
    end

    connection field :stock, node_type: :stock_entry do
      resolve &Resolver.stock/3
    end

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(&match?(%ItemGroup{}, &1))

    interface :resource
  end

  connection(node_type: :item_group, non_null: true)
end
