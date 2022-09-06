defmodule AthenaWeb.Schema.StockExpectation do
  @moduledoc false

  use AthenaWeb, :subschema

  alias Athena.Inventory.StockExpectation

  node object(:stock_expectation) do
    field :item, non_null(:item), resolve: dataloader(RepoDataLoader)
    field :item_group, non_null(:item_group), resolve: dataloader(RepoDataLoader)
    field :location, non_null(:location), resolve: dataloader(RepoDataLoader)
    field :event, non_null(:event), resolve: dataloader(RepoDataLoader)
    field :warning_threshold, non_null(:integer)
    field :important_threshold, non_null(:integer)

    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    is_type_of(&match?(%StockExpectation{}, &1))

    interface :resource
  end

  connection(node_type: :stock_expectation, non_null: true)

  object :stock_expectation_mutations do
    payload field :set_stock_expectation do
      input do
        field :warning_threshold, non_null(:integer)
        field :important_threshold, non_null(:integer)
        field :item_id, non_null(:id)
        field :location_id, non_null(:id)
      end

      output do
        payload_fields(:stock_expectation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, item_id: :item, location_id: :location

      resolve &Resolver.set_stock_expectation/3

      middleware(&build_payload/2)
    end

    payload field :delete_stock_expectation do
      input do
        field :id, non_null(:id)
      end

      output do
        payload_fields(:ok)
      end

      middleware Absinthe.Relay.Node.ParseIDs, id: :stock_expectation

      resolve &Resolver.delete_stock_expectation/3

      middleware(&build_payload/2)
    end
  end
end
